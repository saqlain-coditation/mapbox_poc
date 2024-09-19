import 'package:flutter/material.dart';

class ValueTransitionedBuilder<T> extends StatefulWidget {
  const ValueTransitionedBuilder({
    required this.initialValue,
    required this.builder,
    this.onChanged,
    this.child,
    super.key,
  });

  final T initialValue;
  final Widget Function(
    BuildContext context,
    T value,
    ValueNotifier<T> notifier,
    void Function(T newValue) update,
    Widget? child,
  ) builder;
  final void Function(T value)? onChanged;
  final Widget? child;

  @override
  State<ValueTransitionedBuilder<T>> createState() =>
      _ValueTransitionedBuilderState<T>();
}

class _ValueTransitionedBuilderState<T>
    extends State<ValueTransitionedBuilder<T>> {
  late final ValueNotifier<T> _value;

  @override
  void initState() {
    super.initState();
    _value = ValueNotifier(widget.initialValue);
    _value.addListener(_onChanged);
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  void update(T newValue) {
    _value.value = newValue;
  }

  void _onChanged() {
    widget.onChanged?.call(_value.value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: _value,
      builder: (context, value, child) {
        return widget.builder(context, value, _value, update, child);
      },
      child: widget.child,
    );
  }
}
