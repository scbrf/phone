import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';

List<Article> getTodayArticles(List<FollowingPlanet> following) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return following.map((e) => e.articles).reduce((value, p) => [
        ...value,
        ...p.where((a) {
          DateTime date = DateTime.fromMillisecondsSinceEpoch(a.timestamp);
          return date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;
        })
      ]);
}

List<Article> getUnreadArticles(List<FollowingPlanet> following) {
  return following.map((e) => e.articles).reduce((value, p) => [
        ...value,
        ...p.where((a) {
          return a.read == false;
        })
      ]);
}

List<Article> getStarredArticles(List<FollowingPlanet> following) {
  return following.map((e) => e.articles).reduce((value, p) => [
        ...value,
        ...p.where((a) {
          return a.starred == true;
        })
      ]);
}

Map<String, int> getNumbers(_, StationLoadedAction a) {
  Map<String, int> ret = {};
  ret['today'] = getTodayArticles(a.following).where((a) => !a.read).length;
  ret['unread'] = getUnreadArticles(a.following).where((a) => !a.read).length;
  ret['starred'] = getUnreadArticles(a.following).where((a) => !a.read).length;
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

final appReducer = combineReducers([
  //设置articles和articlesTitle的逻辑
  (AppState s, a) {
    if ((a is! FocusPlanetSelectedAction)) {
      return s;
    }
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
      articlesTitle = p.title;
      articles = p.articles;
    } else {
      FollowingPlanet p = s.following.firstWhere(
          (p) => p.id == s.focusPlanet.substring('following:'.length));
      articlesTitle = p.title;
      articles = p.articles;
    }
    return s.copyWith(articles: articles, articlesTitle: articlesTitle);
  },

  //基本的设置逻辑
  (AppState s, a) => s.copyWith(
        isLoading: combineReducers([
          TypedReducer<bool, FindStationAction>((_, a) => true),
          TypedReducer<bool, LoadStationAction>((_, a) => true),
          TypedReducer<bool, NetworkError>((_, a) => false),
        ])(s.isLoading, a),
        error: combineReducers([
          TypedReducer<String, NetworkError>((_, a) => a.error),
          TypedReducer<String, FindStationAction>((_, a) => ''),
          TypedReducer<String, LoadStationAction>((_, a) => ''),
        ])(s.error, a),
        stations: TypedReducer<List<String>, StationFindedAction>(
            (_, a) => a.stations)(s.stations, a),
        currentStation: TypedReducer<String, CurrentStationSelectedAction>(
            (_, a) => a.currentStation)(s.currentStation, a),
        following: TypedReducer<List<FollowingPlanet>, StationLoadedAction>(
            (_, a) => a.following)(s.following, a),
        planets: TypedReducer<List<Planet>, StationLoadedAction>(
            (_, a) => a.planets)(s.planets, a),
        numbers:
            TypedReducer<Map<String, int>, StationLoadedAction>(getNumbers)(
                s.numbers, a),
        focusPlanet:
            TypedReducer<String, FocusPlanetSelectedAction>((_, a) => a.focus)(
                s.focusPlanet, a),
        ipfsPeers:
            TypedReducer<int, StationLoadedAction>((_, a) => a.ipfsPeers)(
                s.ipfsPeers, a),
        draft: TypedReducer<Article, SetEditorDraftAction>((_, a) => a.draft)(
            s.draft, a),
        focus: TypedReducer<Article, FocusArticleSelectedAction>(
            (_, a) => a.focus)(s.draft, a),
        address: TypedReducer<String, StationLoadedAction>((_, a) => a.address)(
            s.address, a),
      ),
]);
