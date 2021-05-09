import 'package:http/http.dart'
    show BaseClient, Client, StreamedResponse, BaseRequest;

class GoogleAuthClient extends BaseClient {
  final Map<String, String> _headers;
  final Client _client = new Client();

  GoogleAuthClient(this._headers);

  Future<StreamedResponse> send(BaseRequest request) =>
      _client.send(request..headers.addAll(_headers));
}
