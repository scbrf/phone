import 'package:meta/meta.dart';
import 'package:scbrf/models/article.dart';

@immutable
class FollowingPlanet {
  final String id;
  final String title;
  final List<Article> articles;
  const FollowingPlanet(
      {this.id = '', this.title = '', this.articles = const []});
}
