import 'dart:io';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as path;
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scbrf/models/FollowingPlanet.dart';
import 'package:scbrf/utils/write_basic.dart';

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
  final String pinState;
  final String thumbnail;
  final List<String> attachments;
  final FollowingPlanet? planet;
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
      this.thumbnail = '',
      this.planet,
      this.content = '',
      this.pinState = '',
      this.attachments = const [],
      this.title = ""});

  static Article fromJson(Map<String, dynamic> json) {
    return Article(
        id: json['id'] ?? '',
        planetid: json['planetid'] ?? '',
        created: json['created'] ?? 0,
        read: json['read'] ?? false,
        title: json['title'] ?? '',
        url: json['url'] ?? '',
        pinState: json['pinState'] ?? '',
        audioFilename: json['audioFilename'] ?? '',
        videoFilename: json['videoFilename'] ?? '',
        summary: json['summary'] ?? '',
        content: json['content'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
        editable: json['editable'] ?? false,
        attachments: json['attachments'] == null
            ? const []
            : List<String>.from(json['attachments']),
        starred: json['starred'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "planetid": planetid,
      "created": created,
      "read": read,
      "title": title,
      "content": content,
      "audioFilename": audioFilename,
      "videoFilename": videoFilename,
      "attachments": attachments
    };
  }

  static Future<String> getDraftRoot() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    return path.join(appDocPath, 'Drafts');
  }

  Future<String> getDraftDir() async {
    return path.join(await Article.getDraftRoot(), id);
  }

  Future<String> getDraftPreviewPath() async {
    return path.join(await getDraftDir(), 'preview.html');
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
    String? pinState,
    String? id,
    String? thumbnail,
    List<String>? attachments,
    String? planetid,
    FollowingPlanet? planet,
  }) {
    return Article(
        id: id ?? this.id,
        planetid: planetid ?? this.planetid,
        created: created ?? this.created,
        read: read ?? this.read,
        starred: starred ?? this.starred,
        pinState: pinState ?? this.pinState,
        audioFilename: audioFilename ?? this.audioFilename,
        videoFilename: videoFilename ?? this.videoFilename,
        title: title ?? this.title,
        url: url ?? this.url,
        thumbnail: thumbnail ?? this.thumbnail,
        summary: summary ?? this.summary,
        editable: editable ?? this.editable,
        attachments: attachments ?? this.attachments,
        content: content ?? this.content,
        planet: planet ?? this.planet);
  }

  Future<void> renderDraftPreview() async {
    String draftPreviewPath = await getDraftPreviewPath();
    String html = markdownToHtml(content);
    await File(draftPreviewPath)
        .writeAsString(writeBasic.replaceAll('{{ content_html }}', html));
  }

  remove() async {
    Directory(await getDraftDir()).delete(recursive: true);
  }
}
