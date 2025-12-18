class ApiResponse<T> {
  final int statusCode;
  final String message;
  final T? details;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.details,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      statusCode: json['status_code'] as int,
      message: json['message'] as String,
      details: json['details'] != null ? fromJsonT(json['details']) : null,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{statusCode: $statusCode, message: $message, details: $details}';
  }
}
