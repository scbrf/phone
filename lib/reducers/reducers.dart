import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/utils/logger.dart';

final log = getLogger('reducers');

final appReducer = combineReducers([
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
        focusPlanet:
            TypedReducer<String, FocusPlanetSelectedAction>((_, a) => a.focus)(
                s.focusPlanet, a),
        ipfsPeers:
            TypedReducer<int, StationLoadedAction>((_, a) => a.ipfsPeers)(
                s.ipfsPeers, a),
        ipfsGateway:
            TypedReducer<String, StationLoadedAction>((_, a) => a.ipfsGateway)(
                s.ipfsGateway, a),
        draft: TypedReducer<Article, SetEditorDraftAction>((_, a) => a.draft)(
            s.draft, a),
        focus: TypedReducer<Article, FocusArticleSelectedAction>(
            (_, a) => a.focus)(s.draft, a),
        address: TypedReducer<String, StationLoadedAction>((_, a) => a.address)(
            s.address, a),
      ),
]);
