import 'package:dink_rivals/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final originalFlutterErrorHandler = FlutterError.onError;
  final originalPlatformErrorHandler = PlatformDispatcher.instance.onError;

  tearDown(() {
    FlutterError.onError = originalFlutterErrorHandler;
    PlatformDispatcher.instance.onError = originalPlatformErrorHandler;
  });

  test('global error handlers report Flutter and platform errors', () {
    final reportedErrors = <Object>[];
    final reportedStacks = <StackTrace>[];
    final presentedFlutterErrors = <FlutterErrorDetails>[];

    app.installGlobalErrorHandlers(
      reportError: (error, stackTrace) {
        reportedErrors.add(error);
        reportedStacks.add(stackTrace);
      },
      presentFlutterError: presentedFlutterErrors.add,
    );

    final flutterError = StateError('flutter failure');
    final flutterStack = StackTrace.current;
    FlutterError.onError!(
      FlutterErrorDetails(exception: flutterError, stack: flutterStack),
    );

    final platformError = StateError('platform failure');
    final platformStack = StackTrace.current;
    final platformHandled = PlatformDispatcher.instance.onError!(
      platformError,
      platformStack,
    );

    expect(presentedFlutterErrors.single.exception, same(flutterError));
    expect(reportedErrors, [flutterError, platformError]);
    expect(reportedStacks, [flutterStack, platformStack]);
    expect(platformHandled, isTrue);
  });
}
