// shared/models/api_response.dart
// Generic API response wrapper used across all features.

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const ApiResponse.loading()  : data = null, error = null, isLoading = true;
  const ApiResponse.success(this.data) : error = null, isLoading = false;
  const ApiResponse.error(this.error)  : data = null,  isLoading = false;

  bool get hasError   => error != null;
  bool get hasData    => data != null;
}

// Paginated list response from backend
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;
  int  get totalPages => (total / limit).ceil();
}
