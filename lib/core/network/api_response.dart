class ApiResponse<T> {
  final bool ok;
  final T? data;
  final String message;
  final int code;
  final dynamic error;

  ApiResponse({
    required this.ok,
    this.data,
    required this.message,
    required this.code,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      ok: json['ok'] ?? false,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      message: json['message'] ?? 'Sin mensaje',
      code: json['code'] ?? 500,
      error: json['error'],
    );
  }
}