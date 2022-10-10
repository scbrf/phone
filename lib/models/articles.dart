import 'package:meta/meta.dart';
import 'package:scbrf/models/article.dart';

@immutable
class Articles {
  final String title;
  final String focusPlanetId;
  final List<Article> articles;
  const Articles(
      {this.title = '', this.focusPlanetId = '', this.articles = const []});
}
