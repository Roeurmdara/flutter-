class ApiException implements Exception {
  final int? statusCode;
  final dynamic data;

  ApiException(this.statusCode, this.data);

  @override
  String toString() => 'ApiException(statusCode: $statusCode, data: $data)';
}
