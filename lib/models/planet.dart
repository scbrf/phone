import 'package:meta/meta.dart';
import 'package:scbrf/models/article.dart';

@immutable
class Planet {
  final String id;
  final String title;
  final List<Article> articles;
  const Planet({this.id = '', this.title = '', this.articles = const []});
}
