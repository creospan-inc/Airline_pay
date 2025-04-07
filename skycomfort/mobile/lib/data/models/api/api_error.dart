/// Standardized API error model
class ApiError {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic details;
  
  const ApiError({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });
  
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'An error occurred',
      statusCode: json['statusCode'] as int?,
      errorCode: json['code'] as String?,
      details: json['details'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (statusCode != null) 'statusCode': statusCode,
      if (errorCode != null) 'code': errorCode,
      if (details != null) 'details': details,
    };
  }
  
  @override
  String toString() {
    return 'ApiError: $message (Code: $errorCode, Status: $statusCode)';
  }
} 