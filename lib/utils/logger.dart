import 'package:logger/logger.dart';

class SimpleLogPrinter extends LogPrinter {
  final String className;
  SimpleLogPrinter(this.className);
  @override
  List<String> log(LogEvent event) {
    var emoji = PrettyPrinter.levelEmojis[event.level];
    return (['$emoji $className - ${event.message}']);
  }
}

Logger getLogger(String className) {
  return Logger(printer: SimpleLogPrinter(className));
}
