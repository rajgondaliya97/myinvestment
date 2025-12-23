class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  // Get user-friendly error message based on status code
  String getUserMessage() {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Your session has expired. Please login again.';
        case 403:
          return 'You don\'t have permission to access this.';
        case 404:
          return 'User not found. Please check your credentials.';
        case 409:
          return 'This data already exists.';
        case 422:
          return 'Invalid data provided. Please check your input.';
        case 500:
          return 'Server error. Please try again later.';
        case 502:
          return 'Server is not responding. Please try again.';
        case 503:
          return 'Service temporarily unavailable. Please try again later.';
        default:
        // For other status codes, try to extract message from response
          if (message.isNotEmpty && !message.contains('Error ${statusCode}')) {
            return message;
          }
          return 'Something went wrong. Please try again.';
      }
    }

    // Network errors or other exceptions
    if (message.toLowerCase().contains('network')) {
      return 'No internet connection. Please check your network.';
    }
    if (message.toLowerCase().contains('timeout')) {
      return 'Request timeout. Please try again.';
    }
    if (message.toLowerCase().contains('socket')) {
      return 'Connection failed. Please check your network.';
    }

    return 'Something went wrong. Please try again.';
  }
}