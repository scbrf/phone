import 'package:meta/meta.dart';

@immutable
class Article {
  final int timestamp;
  final bool read;
  final bool starred;
  const Article({this.timestamp = 0, this.read = false, this.starred = false});
}
