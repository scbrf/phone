import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  final String className;
  SimpleLogPrinter(this.className);
  @override
  List<String> log(LogEvent evt) {
    var emoji = PrettyPrinter.levelEmojis[evt.level];
    return (['$emoji $className - ${evt.message}']);
  }
}

Logger getLogger(String className) {
  return Logger(printer: SimpleLogPrinter(className));
}
