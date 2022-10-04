import 'package:meta/meta.dart';
import 'package:scbrf/models/article.dart';

@immutable
class FollowingPlanet {
  final String id;
  final String name;
  final List<Article> articles;
  final String cid;
  const FollowingPlanet(
      {this.id = '', this.name = '', this.articles = const [], this.cid = ''});

  static fromJson(Map<String, dynamic> json) {
    return FollowingPlanet(
        id: json['id'],
        name: json['name'],
        cid: json['cid'],
        articles: (json["articles"] as List)
            .map<Article>(
              (e) => Article.fromJson(e),
            )
            .toList());
  }
}
