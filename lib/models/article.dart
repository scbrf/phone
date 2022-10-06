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
  final bool editable;
  final String id;
  final String planetid;
  const Article(
      {this.id = '',
      this.created = 0,
      this.read = false,
      this.starred = false,
      this.editable = false,
      this.url = '',
      this.audioFilename = '',
      this.videoFilename = '',
      this.summary = '',
      this.planetid = '',
      this.title = ""});

  static Article fromJson(Map<String, dynamic> json) {
    return Article(
        id: json['id'] ?? '',
        created: json['created'] ?? 0,
        read: json['read'] ?? false,
        title: json['title'] ?? '',
        url: json['url'] ?? '',
        audioFilename: json['audioFilename'] ?? '',
        videoFilename: json['videoFilename'] ?? '',
        summary: json['summary'] ?? '',
        editable: json['editable'] ?? false,
        starred: json['starred'] ?? false);
  }

  Article copyWith({
    int? created,
    bool? read,
    bool? starred,
    String? audioFilename,
    String? videoFilename,
    String? title,
    String? url,
    String? summary,
    bool? editable,
    String? id,
    String? planetid,
  }) {
    return Article(
      id: id ?? this.id,
      planetid: planetid ?? this.planetid,
      created: created ?? this.created,
      read: read ?? this.read,
      starred: starred ?? this.starred,
      audioFilename: audioFilename ?? this.audioFilename,
      videoFilename: videoFilename ?? this.videoFilename,
      title: title ?? this.title,
      url: url ?? this.url,
      summary: summary ?? this.summary,
      editable: editable ?? this.editable,
    );
  }
}
