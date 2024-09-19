import 'dart:math' as math;

mixin MiscMethods {
  String generateRandomKey({
    bool letter = true,
    bool isNumber = true,
    int length = 8,
  }) {
    const letterLowerCase = 'abcdefghijklmnopqrstuvwxyz';
    const letterUpperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const number = '0123456789';

    var chars = '';
    if (letter) chars += '$letterLowerCase$letterUpperCase';
    if (isNumber) chars += number;

    return List.generate(length, (index) {
      final indexRandom = math.Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }

  Map castMapRecursive(Map<dynamic, dynamic> map) {
    for (var key in map.keys) {
      if (key is Map) {
        castMapRecursive(key);
      }

      if (map[key] is Map) {
        map[key] = castMapRecursive(map[key]);
      }
    }

    return map.keys.firstOrNull is String
        ? Map<String, dynamic>.from(map)
        : map;
  }
}
