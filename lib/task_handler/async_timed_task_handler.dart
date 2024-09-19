part of 'task_handler.dart';

class AsyncTimedTaskHandler extends TaskHandler {
  AsyncTimedTaskHandler(this.milliseconds) : super._();

  final int milliseconds;
  final AsyncHandler _asyncHandler = AsyncHandler();
  late final TimedTaskHandler _timerHandler = TimedTaskHandler(milliseconds);

  @override
  Future<void> handle(FutureOr<void> Function() task) {
    return _timerHandler.handle(() => _asyncHandler.handle(task));
  }

  @override
  Future<T?> handleReturn<T>(FutureOr<T> Function() task) {
    return _timerHandler.handleReturn<T?>(
      () => _asyncHandler.handleReturn(task),
    );
  }

  @override
  void reset() {
    _timerHandler.reset();
    _asyncHandler.reset();
  }
}
