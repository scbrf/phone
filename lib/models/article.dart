import 'package:meta/meta.dart';

@immutable
class Article {
  final int created;
  final bool read;
  final bool starred;
  final String audioFilename;
  final String videoFilename;
  final String title;
  final String content;
  final String url;
  final String summary;
  final bool editable;
  final String id;
  final String planetid;
  final List<String> attachments;
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
      this.content = '',
      this.attachments = const [],
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
        content: json['content'] ?? '',
        editable: json['editable'] ?? false,
        attachments: json['attachments'] ?? const [],
        starred: json['starred'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "created": created,
      "read": read,
      "title": title,
      "content": content,
      "audioFilename": audioFilename,
      "videoFilename": videoFilename,
      "attachments": attachments
    };
  }

  Article copyWith({
    int? created,
    bool? read,
    bool? starred,
    String? audioFilename,
    String? videoFilename,
    String? title,
    String? content,
    String? url,
    String? summary,
    bool? editable,
    String? id,
    List<String>? attachments,
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
        attachments: attachments ?? this.attachments,
        content: content ?? this.content);
  }
}
