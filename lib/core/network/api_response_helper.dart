import 'package:high_school/core/network/unauthorized_handler.dart';

/// Thrown when API returns status 'fail' with an unauthorized-type message.
class UnauthorizedApiException implements Exception {
  UnauthorizedApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Checks decoded API response. If status is 'fail' and message indicates
/// unauthorized (e.g. "Unauthorized: user not found"), triggers [UnauthorizedHandler]
/// and throws [UnauthorizedApiException].
void ensureAuthorized(Map<String, dynamic>? decoded) {
  if (decoded == null) return;
  final status = decoded['status'] as String?;
  final message = (decoded['message'] as String?)?.toLowerCase() ?? '';
  if (status != 'fail') return;
  final isUnauthorized = message.contains('unauthorized') ||
      message.contains('user not found') ||
      message.contains('invalid token') ||
      message.contains('token expired');
  if (!isUnauthorized) return;
  // Trigger logout + redirect to login (fire-and-forget so we don't block)
  UnauthorizedHandler.trigger();
  throw UnauthorizedApiException(decoded['message'] as String? ?? 'Unauthorized');
}
