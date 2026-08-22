class ApiException implements Exception {
  final String message;
  final int code;
  final dynamic error;

  ApiException({
    required this.message,
    required this.code,
    this.error,
  });

  @override
  String toString() => message;
}