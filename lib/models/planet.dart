import 'package:meta/meta.dart';
import 'package:scbrf/models/article.dart';

@immutable
class Planet {
  final String id;
  final String name;
  final List<Article> articles;
  final String ipns;
  final String avatar;
  const Planet(
      {this.id = '',
      this.name = '',
      this.articles = const [],
      this.ipns = '',
      this.avatar = ''});

  static fromJson(Map<String, dynamic> json) {
    return Planet(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        ipns: json['ipns'] ?? '',
        avatar: json['avatar'] ?? '',
        articles: (json["articles"] as List).map<Article>(
          (e) {
            return Article.fromJson(e).copyWith(planetid: json['id']);
          },
        ).toList());
  }
}
