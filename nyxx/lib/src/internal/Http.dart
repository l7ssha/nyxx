part of nyxx;

class HttpBase {
  late final StreamController<HttpResponse> _streamController;

  /// The HTTP client.
  final Http http;

  /// The bucket the request will go into.
  late final HttpBucket bucket;

  /// The path the request is being made to.
  final String path;

  /// The query params.
  final Map<String, String>? queryParams;

  /// The final URI that the request is being made to.
  late final Uri uri;

  /// The HTTP method used.
  final String method;

  /// Headers to be sent.
  final Map<String, String> headers;

  /// The request body.
  dynamic body;

  /// A stream that sends the response when received. Immediately closed after
  /// a value is sent.
  late final Stream<HttpResponse> stream;

  HttpBase._new(this.http, this.method, this.path, this.queryParams,
      this.headers, this.body);

  void _finish() {
    this.uri =
        Uri.https(_Constants.host, _Constants.baseUri + path, queryParams);

    if (http.buckets[uri] == null) http.buckets[uri] = HttpBucket._new(uri);

    this.bucket = http.buckets[uri];

    this._streamController = StreamController<HttpResponse>.broadcast();
    this.stream = _streamController.stream;

    http._client._events.beforeHttpRequestSend
          .add(BeforeHttpRequestSendEvent._new(this));

    if (!http._client._events.beforeHttpRequestSend.hasListener) this.send();
  }

  /// Sends the request off to the bucket to be processed and sent.
  void send() => this.bucket._push(this, http._client);

  void abort() {
    this._streamController.add(HttpResponse._aborted(this));
    this._streamController.close();
  }

  Future<HttpResponse> _execute() async {
    var req = transport.JsonRequest()
      ..uri = this.uri
      ..headers = this.headers;

    if (this.body != null) req.body = this.body;
    if (this.queryParams != null) req.queryParameters = this.queryParams;
    try {
      final r = await req.send(this.method);
      return HttpResponse._fromResponse(this, r);
    } on transport.RequestException catch (e) {
      return new HttpResponse._new(this, e.response?.status!,
          e.response?.statusText!, e.response?.headers!, {});
    }
  }
}

class HttpMultipartRequest extends HttpBase {
  Map<String, transport.MultipartFile> files = Map();
  Map<String, dynamic>? fields;

  HttpMultipartRequest._new(Http http, String method, String path,
      List<AttachmentBuilder> files, this.fields, Map<String, String> headers)
      : super._new(http, method, path, null, headers, null) {
    for (final f in files) {
      this.files[f._name] = f._asMultipartFile();
    }

    super._finish();
  }

  @override
  Future<HttpResponse> _execute() async {
    var req = transport.MultipartRequest()
      ..uri = this.uri
      ..headers = this.headers
      ..files = this.files;

    try {
      if (this.fields != null)
        req.fields.addAll({"payload_json": jsonEncode(this.fields)});
      return HttpResponse._fromResponse(this, await req.send(method));
    } on transport.RequestException catch (e) {
      return HttpResponse._fromResponse(this, e.response);
    }
  }
}

/// A HTTP request.
class HttpRequest extends HttpBase {
  HttpRequest._new(
      Http http,
      String method,
      String path,
      Map<String, String>? queryParams,
      Map<String, String> headers,
      dynamic body)
      : super._new(http, method, path, queryParams, headers, body) {
    super._finish();
  }
}

/// A HTTP response. More documentation can be found at the
/// [w_transport docs](https://www.dartdocs.org/documentation/w_transport/3.0.0/w_transport/Response-class.html)
class HttpResponse {
  /// The HTTP request.
  late HttpBase request;

  /// Whether or not the request was aborted. If true, all other fields will be null.
  late bool aborted;

  /// Status message
  late String statusText;

  /// Status code
  late int status;

  /// Response headers
  late Map<String, String> headers;

  /// Response body
  late dynamic body;

  HttpResponse._new(
      this.request, this.status, this.statusText, this.headers, this.body,
      [this.aborted = false]);

  HttpResponse._aborted(this.request, [this.aborted = true]) {
    this.status = -1;
    this.statusText = "ABORTED";
    this.headers = {};
    this.body = {};
  }

  static HttpResponse _fromResponse(
      HttpBase request, transport.BaseResponse r) {
    var json;
    try {
      json = (r as transport.Response).body.asJson();
    } on Exception {}

    return HttpResponse._new(request, r.status, "", r.headers, json);
  }

  @override
  String toString() =>
      "STATUS [$status], STATUS TEXT: [$statusText], RESPONSE: [$body]";
}

/// A bucket for managing ratelimits.
class HttpBucket {
  /// The url that this bucket is handling requests for.
  Uri url;

  /// The number of requests that can be made.
  late int limit;

  /// The number of remaining requests that can be made. May not always be accurate.
  int rateLimitRemaining = 2;

  /// When the ratelimits reset.
  late DateTime? rateLimitReset;

  /// The time difference between you and Discord.
  //Duration timeDifference;

  /// A queue of requests waiting to be sent.
  List<HttpBase> requests = <HttpBase>[];

  /// Whether or not the bucket is waiting for a request to complete
  /// before continuing.
  bool waiting = false;

  HttpBucket._new(this.url);

  void _push(HttpBase request, Nyxx client) {
    this.requests.add(request);
    this._handle(client);
  }

  void _handle(Nyxx client) {
    if (this.waiting || this.requests.length == 0) return;
    this.waiting = true;

    this._execute(this.requests[0], client);
  }

  void _execute(HttpBase request, Nyxx client) async {
    if (this.rateLimitRemaining == null || this.rateLimitRemaining > 1) {
      final HttpResponse r = await request._execute();
      this.limit = r.headers['x-ratelimit-limit'] != null
          ? int.parse(r.headers['x-ratelimit-limit'])
          : null;
      this.rateLimitRemaining = r.headers['x-ratelimit-remaining'] != null
          ? int.parse(r.headers['x-ratelimit-remaining'])
          : null;
      this.rateLimitReset = r.headers['x-ratelimit-reset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(r.headers['x-ratelimit-reset']) * 1000,
              isUtc: true)
          : null;

      if (r.status == 429) {
        client._events.onRatelimited
            .add(RatelimitEvent._new(request, false, r));
        request.http._logger.warning(
            "Rate limitted via 429 on endpoint: ${request.path}. Trying to send request again after timeout...");
        Timer(Duration(milliseconds: (r.body['retry_after'] as int) ?? 0 + 100),
            () => this._execute(request, client));
      } else {
        this.waiting = false;
        this.requests.remove(request);
        request._streamController.add(r);
        request._streamController.close();
        this._handle(client);
      }
    } else {
      final Duration waitTime =
          this.rateLimitReset == null ? Duration.zero :
            this.rateLimitReset!.difference(DateTime.now().toUtc()) +
                Duration(milliseconds: 250);
      if (waitTime.isNegative) {
        this.rateLimitRemaining = 2;
        this._execute(request, client);
      } else {
        client._events.onRatelimited.add(RatelimitEvent._new(request, true));
        request.http._logger.warning(
            "Rate limitted internally on endpoint: ${request.path}. Trying to send request again after timeout...");
        Timer(waitTime, () {
          this.rateLimitRemaining = 2;
          this._execute(request, client);
        });
      }
    }
  }
}

/// The client's HTTP client.
class Http {
  Nyxx _client;

  /// The buckets.
  Map<Uri, HttpBucket> buckets = Map();

  /// Headers sent on every request.
  Map<String, String> _headers = Map();

  Logger _logger = Logger("Http");

  Http._new(this._client) {
    this._headers['Authorization'] = "Bot ${this._client._token}";

    if (!browser)
      this._headers['User-Agent'] =
          "Nyxx (${_Constants.repoUrl}, ${_Constants.version})";
  }

  /// Adds AUDIT_LOG header to request
  Map<String, String> _addAuditReason(String reason) {
    if (reason.length > 512)
      throw new Exception(
          "X-Audit-Log-Reason header cannot be longer than 512 characters");

    return <String, String>{
      "X-Audit-Log-Reason": "${reason == null ? "" : reason}"
    };
  }

  /// Creates headers for request
  void _addHeaders(HttpBase request, String? reason) {
    final Map<String, String> _headers = Map.from(this._headers);
    if (!browser && reason != null && reason != "")
      _headers.addAll(_addAuditReason(reason));

    request.headers.addAll(_headers);
  }

  /// Sends a HTTP request.
  Future<HttpResponse> send(String method, String path,
      {dynamic body,
      Map<String, String>? queryParams,
      bool beforeReady = false,
      Map<String, String> headers = const {},
      String? reason}) async {
    HttpRequest request =
        HttpRequest._new(this, method, path, queryParams, _headers, body);

    _addHeaders(request, reason);
    return _executeRequest(request);
  }

  /// Sends multipart request
  Future<HttpResponse> sendMultipart(
      String method, String path, List<AttachmentBuilder> files,
      {Map<String, dynamic>? data,
      bool beforeReady = false,
      String? reason}) async {
    HttpMultipartRequest request = HttpMultipartRequest._new(this, method, path,
        files, data, Map.from(this._headers)..addAll(_headers));

    _addHeaders(request, reason);
    return _executeRequest(request);
  }

  Future<HttpResponse> _executeRequest(HttpBase request) async {
    await for (HttpResponse r in request.stream) {
      if (!r.aborted && r.status >= 200 && r.status < 300) {
        if (_client != null)
          _client._events.onHttpResponse.add(HttpResponseEvent._new(r));
        return r;
      } else {
        if (_client != null)
          _client._events.onHttpError.add(HttpErrorEvent._new(r));
        return Future.error(r);
      }
    }

    return Future.error("Didn't got any response");
  }
}
