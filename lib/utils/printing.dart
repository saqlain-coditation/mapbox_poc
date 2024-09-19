import 'logger.dart';
import 'methods/lib_methods.dart';

void printCustom(dynamic object, [Logger logger = Logger.blue]) {
  var data = const LibMethods().prettifyMap(object);
  logger.log(data);
}

void printMessages(dynamic object) {
  printCustom(object, Logger.white);
}

void printError(dynamic object) {
  printCustom(object, Logger.magenta);
}

void printRemote(dynamic object) {
  printCustom(object, Logger.yellow);
}

void printLocal(dynamic object) {
  printCustom(object, Logger.green);
}

void printImportant(dynamic object) {
  printCustom(object, Logger.red);
}

void printPersistent(dynamic object) {
  // printCustom(object, Logger.cyan);
}
