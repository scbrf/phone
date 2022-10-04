import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';

final appReducer = combineReducers([
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
