import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'separator_builder.dart';

extension ExtendedList<E> on List<E> {
  List<E> replaceElementAt(int index, E element) {
    replaceRange(index, index + 1, [element]);
    return this;
  }

  List<E> replaceElement(E oldElement, E newElement) {
    return replaceElementAt(indexOf(oldElement), newElement);
  }

  void replaceWhere(bool Function(E element) test, E newElement) {
    var oldElement = findWhere(test);
    if (oldElement != null) {
      replaceElement(oldElement, newElement);
    }
  }

  List<E> get distinct => toSet().toList();

  List<E> distinctBy<T>(T Function(E element) identity) {
    return Map.fromEntries(map((e) => MapEntry<T, E>(identity(e), e))).values.toList();
  }

  List<List<E>> groupBy(int count) {
    List<List<E>> groups = [];
    var len = (length ~/ 3) * 3;

    for (var i = 0; i < len; i = i + 3) {
      groups.add(sublist(i, i + 3));
    }

    groups.add(sublist(len, length));

    return groups;
  }

  List<E> moveItemToEnd<T>(List<E> list, E item) {
    int index = list.indexOf(item);

    if (index != -1) {
      // Remove the item from its current position
      list.removeAt(index);
      // Add the item to the end of the list
      list.add(item);
    }

    return list;
  }

  List<E> separated(E Function(int index) separator) {
    return SeparatorBuilder<E, E>(
      originalList: this,
      separatorBuilder: separator,
      itemBuilder: (index, itemData) => itemData,
    ).separatedList;
  }
}

extension ExtendedIterable<E> on Iterable<E> {
  E? findWhere(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  E? get maybeFirst => length > 0 ? first : null;

  Iterable<R> mapIndexed<R>(R Function(int index, E element) convert) sync* {
    var index = 0;
    for (var element in this) {
      yield convert(index++, element);
    }
  }
}

/// Extensions that apply to iterables with a nullable element type.
extension ExtendedNullIterable<T> on Iterable<T?> {
  /// The non-`null` elements of this `Iterable`.
  ///
  /// Returns an iterable which emits all the non-`null` elements
  /// of this iterable, in their original iteration order.
  ///
  /// For an `Iterable<X?>`, this method is equivalent to `.whereType<X>()`.
  Iterable<T> get whereNotNull sync* {
    for (var element in this) {
      if (element != null) yield element;
    }
  }
}

extension PageNumber on PageController {
  double get pageNumber {
    var pageNumber = initialPage.toDouble();
    try {
      if (hasClients) {
        pageNumber = page ?? pageNumber;
      }
    } catch (e) {
      // Do Nothing
    }
    return pageNumber;
  }
}

// extension ExtendedDateFormat on DateTime {
//   String convertDate(String format) {
//     var dateFormat = DateFormat(format);
//     var formattedDate = dateFormat.format(this);
//     return formattedDate;
//   }

//   int get accumulatedDate => millisecondsSinceEpoch ~/ (3600000 * 24);
//   DateTime get toDateOnly => DateTime(year, month, day);

//   DateTime get toDateOnlyEnd => DateTime(year, month, day, 23, 59, 59);

//   DateTime get toMonthOnly => DateTime(year, month);
// }

extension ExtendedString on String {
  String get capitalize =>
      length > 1 ? '${this[0].toUpperCase()}${substring(1)}' : this[0].toUpperCase();

  String convertCase(String separator) {
    var result = replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.groups([1]).first!}');
    result = result.trim();
    return result.split(' ').join(separator).toLowerCase();
  }

  String get snakeCase => convertCase("_");

  String pluralize(int count) => count == 1 ? this : '${this}s';
}

extension ExtendedColor on Color {
  String get hexCode => '#${value.toRadixString(16).substring(2)}';

  WidgetStateProperty<Color> get statePropertyColor => WidgetStateProperty.all<Color>(this);
}

extension ExtendedDouble on double {
  double get fraction {
    if (truncate() == 0) return this;
    return remainder(truncate());
  }
}

extension ExtendedNumbers on num {
  double toDoubleAsFixed(int length) {
    num pow = math.pow(10, length);
    return (this * pow).round() / pow;
  }
}

extension ExtendedAnimation<T> on Animation<T> {
  Animation<double>? get parent {
    if (this is AnimationWithParentMixin<double>) {
      return (this as AnimationWithParentMixin<double>).parent;
    } else {
      return null;
    }
  }

  bool get isForward => status == AnimationStatus.forward || status == AnimationStatus.completed;

  bool get isReverse => status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
}

extension ExtendedDuration on Duration {
  String get parse {
    var hour = inHours.toString().padLeft(2, '0');
    var min = inMinutes.toString().padLeft(2, '0');
    var sec = inSeconds.toString().padLeft(2, '0');
    var milliSec = inMilliseconds.toString().padLeft(2, '0');

    return '$hour:$min:$sec:$milliSec}';
  }
}

extension ExtendedUri on Uri {
  Uri addQueryParameters(Map<String, dynamic> queryParameters) {
    var uri = replace();

    var uriQueryParams = {...uri.queryParametersAll};
    for (var param in queryParameters.entries) {
      if (uriQueryParams.containsKey(param.key)) {
        uriQueryParams[param.key] = [...uriQueryParams[param.key]!];
        uriQueryParams[param.key]!.add(param.value);
      } else {
        uriQueryParams[param.key] = [param.value];
      }
    }

    uri = uri.replace(queryParameters: uriQueryParams);
    return uri;
  }
}

extension UriTransformation on String {
  String addQueryParameters(Map<String, dynamic> queryParameters) {
    return Uri.parse(this).addQueryParameters(queryParameters).toString();
  }
}

extension DateTimeExtension on DateTime {
  int differenceInYears(DateTime other) {
    int yearDiff = other.year - year;

    if (month > other.month || (month == other.month && day > other.day)) {
      yearDiff--;
    }

    return yearDiff.abs();
  }
}

extension ExtendedBoxConstraints on BoxConstraints {
  BoxConstraints expandBelowInfinity() {
    return BoxConstraints(
      minWidth: maxWidth.isInfinite ? minWidth : maxWidth,
      maxWidth: maxWidth,
      minHeight: maxHeight.isInfinite ? minHeight : maxHeight,
      maxHeight: maxHeight,
    );
  }
}

extension GlobalKeyExtension on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }

  Rect? get layoutPosition {
    final renderObject = findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return null;
    final renderBox = renderObject;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    return rect;
  }
}
