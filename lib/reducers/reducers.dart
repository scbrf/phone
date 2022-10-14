import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/utils/logger.dart';

final log = getLogger('reducers');

final appReducer = combineReducers([
  (AppState s, action) {
    if (action is MarkArticleReadedSuccAction) {
      return s.copyWith(
          following: s.following.map((p) {
        if (p.id != action.planetid) return p;
        return p.copyWith(
            articles: p.articles.map((a) {
          if (a.id != action.articleid) return a;
          return a.copyWith(read: true);
        }).toList());
      }).toList());
    }
    if (action is TriggerArticleStarredSuccAction) {
      return s.copyWith(
          following: s.following.map((p) {
        if (p.id != action.target.planetid) return p;
        return p.copyWith(
            articles: p.articles.map((a) {
          if (a.id != action.target.id) return a;
          return a.copyWith(starred: !action.target.starred);
        }).toList());
      }).toList());
    }
    return s;
  },
  //基本的设置逻辑
  (AppState s, a) => s.copyWith(
        state: combineReducers([
          TypedReducer<LoadState, FindStationAction>((_, a) {
            log.d(
                'reducer called to set load State with action FindStationAction');
            return const LoadState(
                isLoading: true, progress: '正在查找运行点...', error: '');
          }),
          TypedReducer<LoadState, LoadStationAction>((_, a) => const LoadState(
              isLoading: true, progress: '正在加载数据...', error: '')),
          TypedReducer<LoadState, StationFindedAction>((_, a) =>
              const LoadState(isLoading: false, progress: '', error: '')),
          TypedReducer<LoadState, NetworkError>(
              (_, a) => LoadState(isLoading: false, error: a.error)),
        ])(s.state, a),
        stations: TypedReducer<List<String>, StationFindedAction>(
            (_, a) => a.stations)(s.stations, a),
        currentStation: TypedReducer<String, CurrentStationSelectedAction>(
            (_, a) => a.currentStation)(s.currentStation, a),
        following: TypedReducer<List<FollowingPlanet>, StationLoadedAction>(
            (_, a) => a.following)(s.following, a),
        planets: TypedReducer<List<Planet>, StationLoadedAction>(
            (_, a) => a.planets)(s.planets, a),
        fair:
            TypedReducer<List<Article>, StationLoadedAction>((_, a) => a.fair)(
                s.fair, a),
        focusPlanet:
            TypedReducer<String, FocusPlanetSelectedAction>((_, a) => a.focus)(
                s.focusPlanet, a),
        ipfsPeers:
            TypedReducer<int, StationLoadedAction>((_, a) => a.ipfsPeers)(
                s.ipfsPeers, a),
        ipfsGateway:
            TypedReducer<String, StationLoadedAction>((_, a) => a.ipfsGateway)(
                s.ipfsGateway, a),
        draft: combineReducers([
          TypedReducer<Article, SetEditorDraftAction>((_, a) => a.draft),
          TypedReducer<Article, DraftTitleChangeAction>(
              (s, a) => s.copyWith(title: a.value)),
          TypedReducer<Article, DraftContentChangeAction>(
              (s, a) => s.copyWith(content: a.value))
        ])(s.draft, a),
        focus: TypedReducer<Article, FocusArticleSelectedAction>(
            (_, a) => a.focus)(s.draft, a),
        address: TypedReducer<String, StationLoadedAction>((_, a) => a.address)(
            s.address, a),
      ),
]);
