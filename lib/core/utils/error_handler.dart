import 'package:injectable/injectable.dart';
import 'logger.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';

abstract class ErrorHandler {
  Future<void> handleError(dynamic error, StackTrace? stackTrace,
      {String? context});
  Future<void> handleAsyncError(Future<void> Function() function,
      {String? context});
}

@Injectable(as: ErrorHandler)
class ErrorHandlerImpl implements ErrorHandler {
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;

  ErrorHandlerImpl(this._analyticsService, this._crashlyticsService);

  @override
  Future<void> handleError(dynamic error, StackTrace? stackTrace,
      {String? context}) async {
    try {
      // Log the error
      Logger.error(
        'Error occurred${context != null ? ' in $context' : ''}',
        error,
        stackTrace,
      );

      // Send to crashlytics
      await _crashlyticsService.logError(error, stackTrace);

      // Log to analytics
      await _analyticsService.logEvent(
        'app_error',
        parameters: {
          'error_type': error.runtimeType.toString(),
          'error_message': error.toString(),
          'context': context ?? 'unknown',
        },
      );

      // Set custom crashlytics keys
      if (context != null) {
        await _crashlyticsService.setCustomKey('error_context', context);
      }
      await _crashlyticsService.setCustomKey(
          'error_type', error.runtimeType.toString());
      await _crashlyticsService.setCustomKey('error_message', error.toString());
    } catch (e, st) {
      // Fallback error logging if error handling itself fails
      Logger.error('Error in error handler', e, st);
    }
  }

  @override
  Future<void> handleAsyncError(Future<void> Function() function,
      {String? context}) async {
    try {
      await function();
    } catch (error, stackTrace) {
      await handleError(error, stackTrace, context: context);
    }
  }
}
