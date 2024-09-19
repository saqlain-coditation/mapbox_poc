import 'dart:async';

part 'async_handler.dart';
part 'async_timed_task_handler.dart';
part 'timed_task_handler.dart';

abstract class TaskHandler {
  const TaskHandler._();
  factory TaskHandler.async([bool singleUse = false]) =>
      AsyncHandler(singleUse);
  factory TaskHandler.timed(int milliseconds) => TimedTaskHandler(milliseconds);
  factory TaskHandler.asyncTimed(int milliseconds) =>
      AsyncTimedTaskHandler(milliseconds);

  void reset();
  Future<void> handle(FutureOr<void> Function() task);
  Future<T?> handleReturn<T>(FutureOr<T> Function() task);

  Future<void> Function() handler(FutureOr<void> Function() task) =>
      () => handle(task);
  Future<T?> Function() handlerReturn<T>(FutureOr<T> Function() task) =>
      () => handleReturn<T>(task);
}
