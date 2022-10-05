import 'package:meta/meta.dart';

@immutable
class Article {
  final int created;
  final bool read;
  final bool starred;
  final String audioFilename;
  final String videoFilename;
  final String title;
  final String url;
  final String summary;
  const Article(
      {this.created = 0,
      this.read = false,
      this.starred = false,
      this.url = '',
      this.audioFilename = '',
      this.videoFilename = '',
      this.summary = '',
      this.title = ""});

  static fromJson(Map<String, dynamic> json) {
    return Article(
        created: json['created'],
        read: json['read'] ?? false,
        title: json['title'] ?? '',
        url: json['url'] ?? '',
        audioFilename: json['audioFilename'] ?? '',
        videoFilename: json['videoFilename'] ?? '',
        summary: json['summary'] ?? '',
        starred: json['starred'] ?? false);
  }
}
