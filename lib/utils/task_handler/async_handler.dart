part of 'task_handler.dart';

class AsyncHandler extends TaskHandler {
  AsyncHandler([this.locked = false]) : super._();
  bool _isProcessing = false;
  bool _taskDone = false;
  final bool locked;

  bool get taskDone => _taskDone;

  /// Use with Caution
  @override
  void reset() {
    if (locked && _taskDone) {
      _isProcessing = false;
      _taskDone = false;
    }
  }

  @override
  Future<void> handle(FutureOr<void> Function() task) async {
    if (!_isProcessing) {
      _isProcessing = true;
      await task();
      _taskDone = true;
      if (!locked) {
        _isProcessing = false;
      }
    }
  }

  @override
  Future<T?> handleReturn<T>(FutureOr<T> Function() task) async {
    if (!_isProcessing) {
      _isProcessing = true;
      var result = await task();
      _taskDone = true;
      if (!locked) {
        _isProcessing = false;
      }
      return result;
    }
    return null;
  }
}
