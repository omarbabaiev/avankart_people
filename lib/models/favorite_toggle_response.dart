class FavoriteToggleResponse {
  final String status;
  final String message;

  FavoriteToggleResponse({
    required this.status,
    required this.message,
  });

  /// Factory method to create from JSON
  factory FavoriteToggleResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteToggleResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }

  /// Check if favorite was added
  bool get isAdded => message == 'added';

  /// Check if favorite was removed
  bool get isRemoved => message == 'removed';

  /// Check if message is valid (added or removed)
  bool get isValid => isAdded || isRemoved;
}

/// Exception for favorite toggle errors
class FavoriteToggleException implements Exception {
  final String message;
  FavoriteToggleException(this.message);

  @override
  String toString() => message;
}
