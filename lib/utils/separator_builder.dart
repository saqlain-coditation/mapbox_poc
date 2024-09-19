import 'dart:math';

class SeparatorBuilder<DataType, ItemType> {
  SeparatorBuilder({
    required this.originalList,
    required ItemType Function(int index) separatorBuilder,
    required ItemType Function(int index, DataType itemData) itemBuilder,
  })  : _itemBuilder = itemBuilder,
        _separatorBuilder = separatorBuilder;

  final List<DataType> originalList;
  final ItemType Function(int index, DataType itemData) _itemBuilder;
  final ItemType Function(int index) _separatorBuilder;

  int get length => max(0, originalList.length * 2 - 1);
  int get originalLength => originalList.length;

  ItemType itemBuilder(int index) {
    final ItemType item;
    final itemIndex = index ~/ 2;

    if (index.isEven) {
      // Build Item : Starts from Zero
      item = _itemBuilder(itemIndex, originalList[itemIndex]);
    } else {
      // Build Separator
      item = _separatorBuilder(itemIndex);
    }

    return item;
  }

  List<ItemType> get separatedList {
    return listSeparator<ItemType>(
      originalList
          .asMap()
          .map((index, data) => MapEntry(index, _itemBuilder(index, data)))
          .values
          .toList(),
      (index) => _separatorBuilder(index),
    );
  }

  static List<ItemType> listSeparator<ItemType>(
    List<ItemType> originalList,
    ItemType Function(int index) separatorBuilder,
  ) {
    final int length = max(0, originalList.length * 2 - 1);

    var separatedList = List<ItemType>.generate(
      length,
      (index) {
        final ItemType item;
        final itemIndex = index ~/ 2;

        if (index.isEven) {
          // Build Item : Starts from Zero
          item = originalList[itemIndex];
        } else {
          // Build Separator
          item = separatorBuilder(itemIndex);
        }

        return item;
      },
    );

    return separatedList;
  }
}
