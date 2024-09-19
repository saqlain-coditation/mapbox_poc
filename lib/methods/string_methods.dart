import 'dart:convert';

mixin StringMethods {
  String prettifyMap(dynamic input) {
    try {
      var encoder = JsonEncoder.withIndent('  ', (obj) => obj.toString());
      var prettyprint = encoder.convert(input);
      return prettyprint;
    } catch (e) {
      return input.toString();
    }
  }

  void printWrapped(String text, void Function(dynamic object) print) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
