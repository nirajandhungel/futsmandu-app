class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiMeta? meta;
  final String? code;
  final String? timestamp;
  final ApiError? error; // Add error field

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.meta,
    this.code,
    this.timestamp,
    this.error, // Add error field
  });

  factory ApiResponse.fromJson(
  Map<String, dynamic> json,
  T Function(dynamic)? fromJsonT,
) {
  print('📦 Parsing ApiResponse: ${json.keys}');
  
  ApiError? apiError;
  
  // Parse error field if it exists
  if (json.containsKey('error') && json['error'] != null) {
    print('📦 Found error field: ${json['error']}');
    final errorData = json['error'];
    
    if (errorData is Map<String, dynamic>) {
      apiError = ApiError.fromJson(errorData);
    } else {
      apiError = ApiError.fromJson(errorData);
    }
    print('📦 Parsed ApiError: ${apiError?.message}');
  }
  
  return ApiResponse<T>(
    success: json['success'] ?? false,
    data: json['data'] != null && fromJsonT != null
        ? fromJsonT(json['data'])
        : json['data'],
    message: json['message']?.toString(),
    meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
    code: json['code']?.toString(),
    timestamp: json['timestamp']?.toString(),
    error: apiError,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'meta': meta?.toJson(),
      'code': code,
      'timestamp': timestamp,
      'error': error?.toJson(),
    };
  }

  // Helper method to get error message
  String? get errorMessage {
    if (error != null) return error!.message;
    if (message != null) return message;
    return null;
  }
}

class ApiMeta {
  final String? timestamp;
  final int? page;
  final int? pageSize;
  final int? totalPages;
  final int? totalItems;

  ApiMeta({
    this.timestamp,
    this.page,
    this.pageSize,
    this.totalPages,
    this.totalItems,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      timestamp: json['timestamp'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'page': page,
      'pageSize': pageSize,
      'totalPages': totalPages,
      'totalItems': totalItems,
    };
  }
}
class ApiError {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    this.code,
    this.details,
  });

  factory ApiError.fromJson(dynamic json) {
    print('🔧 Parsing ApiError from: $json');
    print('🔧 Type: ${json.runtimeType}');
    
    try {
      if (json is Map<String, dynamic>) {
        // Check if it's the full error object structure
        if (json.containsKey('message') || json.containsKey('code')) {
          // Direct structure: {message: "...", code: "...", details: {...}}
          return ApiError(
            message: json['message']?.toString() ?? 'An error occurred',
            code: json['code']?.toString(),
            details: json['details'] is Map ? 
                    Map<String, dynamic>.from(json['details']) : null,
          );
        } else {
          // Might be a Map but not our structure, convert to string
          return ApiError(
            message: json.toString(),
            code: null,
            details: null,
          );
        }
      } else if (json is String) {
        // Just a string error
        return ApiError(
          message: json,
          code: null,
          details: null,
        );
      }
    } catch (e) {
      print('❌ Error parsing ApiError: $e');
    }
    
    // Fallback
    return ApiError(
      message: json.toString(),
      code: null,
      details: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'details': details,
    };
  }

  String? get suggestion {
    if (details != null && details!['suggestion'] != null) {
      return details!['suggestion'].toString();
    }
    return null;
  }

  String get formattedMessage {
    final suggestion = this.suggestion;
    if (suggestion != null && suggestion.isNotEmpty) {
      return '$message\n\n$suggestion';
    }
    return message;
  }

  @override
  String toString() => message;
}