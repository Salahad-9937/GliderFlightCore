import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../architecture/failure.dart';
import '../architecture/result.dart';
import 'i_network_client.dart';

/// Реализация сетевого клиента на базе пакета `http`.
class HttpNetworkClient implements INetworkClient {
  final String _baseUrl;
  final http.Client _client;

  /// Создает экземпляр клиента.
  HttpNetworkClient(this._baseUrl, this._client);

  @override
  Future<Result<dynamic, Failure>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl$path',
      ).replace(queryParameters: queryParameters);
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 3));

      return _handleResponse(response);
    } on SocketException {
      return const Error(NetworkFailure('Нет связи с устройством'));
    } on Exception catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Result<dynamic, Failure>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final response = await _client
          .post(
            uri,
            headers: {...?headers, 'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 5));

      return _handleResponse(response);
    } on SocketException {
      return const Error(NetworkFailure('Нет связи с устройством'));
    } on Exception catch (e) {
      return Error(NetworkFailure(e.toString()));
    }
  }

  @override
  Stream<String> stream(String path, {Map<String, dynamic>? body}) async* {
    final request = http.Request('POST', Uri.parse('$_baseUrl$path'));
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    try {
      final response = await _client.send(request);
      if (response.statusCode == 200) {
        yield* response.stream.transform(utf8.decoder);
      } else {
        throw ServerFailure('Ошибка потока', response.statusCode);
      }
    } on Exception {
      rethrow;
    }
  }

  /// Универсальный обработчик HTTP ответов.
  Result<dynamic, Failure> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return Success(jsonDecode(utf8.decode(response.bodyBytes)));
      } catch (e) {
        return const Error(DataFailure('Ошибка парсинга данных'));
      }
    }

    return Error(
      ServerFailure(
        'Ошибка сервера: ${response.statusCode}',
        response.statusCode,
      ),
    );
  }
}
