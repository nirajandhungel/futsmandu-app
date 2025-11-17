class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiMeta? meta;
  final String? code;
  final String? timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.meta,
    this.code,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic)? fromJsonT,
      ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
      code: json['code'],
      timestamp: json['timestamp'],
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
    };
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
  final String? timestamp;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    this.code,
    this.timestamp,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'An error occurred',
      code: json['code'],
      timestamp: json['timestamp'],
      details: json['details'],
    );
  }

  @override
  String toString() => message;
}