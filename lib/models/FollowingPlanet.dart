import 'package:meta/meta.dart';
import 'package:scbrf/models/article.dart';

@immutable
class FollowingPlanet {
  final String id;
  final String name;
  final List<Article> articles;
  final String cid;
  final String avatar;
  const FollowingPlanet(
      {this.id = '',
      this.name = '',
      this.articles = const [],
      this.cid = '',
      this.avatar = ''});

  static fromJson(Map<String, dynamic> json) {
    var p = FollowingPlanet(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        cid: json['cid'] ?? '',
        avatar: json['avatar'] ?? '',
        articles: (json["articles"] as List).map<Article>(
          (e) {
            return Article.fromJson(e).copyWith(planetid: json['id']);
          },
        ).toList());
    return p.copyWith(
        articles: p.articles.map((e) => e.copyWith(planet: p)).toList());
  }

  FollowingPlanet copyWith(
      {String? id,
      String? name,
      List<Article>? articles,
      String? cid,
      String? avatar}) {
    return FollowingPlanet(
        id: id ?? this.id,
        name: name ?? this.name,
        articles: articles ?? this.articles,
        cid: cid ?? this.cid,
        avatar: avatar ?? this.avatar);
  }
}
