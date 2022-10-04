import 'package:meta/meta.dart';

@immutable
class Article {
  final int created;
  final bool read;
  final bool starred;
  final String title;
  const Article(
      {this.created = 0,
      this.read = false,
      this.starred = false,
      this.title = ""});

  static fromJson(Map<String, dynamic> json) {
    return Article(
        created: json['created'],
        read: json['read'] ?? false,
        title: json['title'] ?? '',
        starred: json['starred'] ?? false);
  }
}
