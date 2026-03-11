/// Global handler for API responses that indicate unauthorized (e.g. user not found).
/// Set [onUnauthorized] in main after creating router and auth provider.
class UnauthorizedHandler {
  UnauthorizedHandler._();

  /// Called when any API returns status 'fail' with message like "Unauthorized: user not found".
  /// Should clear session and navigate to login.
  static Future<void> Function()? onUnauthorized;

  /// Triggers the handler (logout + redirect to login). Call when such a response is detected.
  static Future<void> trigger() async {
    await onUnauthorized?.call();
  }
}
