import 'package:scbrf/models/models.dart';
import 'package:scbrf/utils/logger.dart';

var log = getLogger('selectors');

List<Article> getTodayArticles(List<FollowingPlanet> following) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return following.fold<List<Article>>(
      [],
      (value, p) => [
            ...value,
            ...p.articles.where((a) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(a.created);
              return date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
            })
          ]);
}

List<Article> getUnreadArticles(List<FollowingPlanet> following) {
  return following.fold<List<Article>>(
      [],
      (value, p) => [
            ...value,
            ...p.articles.where((a) {
              return a.read == false;
            })
          ]);
}

List<Article> getStarredArticles(List<FollowingPlanet> following) {
  return following.fold<List<Article>>(
      [],
      (value, p) => [
            ...value,
            ...p.articles.where((a) {
              return a.starred == true;
            })
          ]);
}

Map<String, int> numberSelector(AppState a) {
  Map<String, int> ret = {};
  ret['today'] = getTodayArticles(a.following).where((a) => !a.read).length;
  ret['unread'] = getUnreadArticles(a.following).where((a) => !a.read).length;
  ret['starred'] = getStarredArticles(a.following).where((a) => !a.read).length;
  for (int i = 0; i < a.following.length; i++) {
    ret['following:${a.following[i].id}'] =
        a.following[i].articles.where((a) => !a.read).length;
  }
  for (int i = 0; i < a.planets.length; i++) {
    ret['my:${a.planets[i].id}'] =
        a.planets[i].articles.where((a) => !a.read).length;
  }
  return ret;
}

Articles articlesSelector(AppState s) {
  String articlesTitle;
  List<Article> articles = [];
  if (s.focusPlanet == 'today') {
    articlesTitle = 'Today';
    articles = getTodayArticles(s.following);
  } else if (s.focusPlanet == 'unread') {
    articlesTitle = 'Unread';
    articles = getUnreadArticles(s.following);
  } else if (s.focusPlanet == 'starred') {
    articlesTitle = 'Starred';
    articles = getStarredArticles(s.following);
  } else if (s.focusPlanet.startsWith('my:')) {
    Planet p = s.planets
        .firstWhere((p) => p.id == s.focusPlanet.substring('my:'.length));
    articlesTitle = p.name;
    articles = p.articles;
  } else {
    FollowingPlanet p = s.following.firstWhere(
        (p) => p.id == s.focusPlanet.substring('following:'.length));
    articlesTitle = p.name;
    articles = p.articles;
  }
  return Articles(
      title: articlesTitle, focusPlanetId: s.focusPlanet, articles: articles);
}
