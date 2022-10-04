import 'package:meta/meta.dart';

@immutable
class Article {
  final int created;
  final bool read;
  final bool starred;
  const Article({this.created = 0, this.read = false, this.starred = false});

  static fromJson(Map<String, dynamic> json) {
    return Article(
        created: json['created'],
        read: json['read'] ?? false,
        starred: json['starred'] ?? false);
  }
}
