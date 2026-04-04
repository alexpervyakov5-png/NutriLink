class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Ошибка сервера']);
  @override
  String toString() => message;
}

class CacheException implements Exception {}