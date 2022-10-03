import 'package:scbrf/models/models.dart';

//系统启动的时候，发起搜索Station的行为
class FindStationAction {}

//可能会搜索到多个或者0个，如果搜索到多个，只能让用户选一个啦
class StationFindedAction {
  final List<String> stations;
  StationFindedAction(this.stations);
}

//用户选择一个Station
class CurrentStationSelectedAction {
  final String currentStation;
  CurrentStationSelectedAction(this.currentStation);
}

//发起一个LoadStation的Action
class LoadStationAction {}

//成功从网络读取到一个Station的详情,
class StationLoadedAction {
  final List<FollowingPlanet> following;
  final List<Planet> planets;
  final int ipfsPeers;
  final String address;
  StationLoadedAction(this.address,
      {this.following = const [], this.planets = const [], this.ipfsPeers = 0});
}

//也坑会遇到网络错误
class NetworkError {
  String error;
  NetworkError(this.error);
}

//选择Today，Unread，Starred 或者是某个Planet或者FollwingPlanet
class FocusPlanetSelectedAction {
  final String focus;
  FocusPlanetSelectedAction(this.focus);
}

class FocusArticleSelectedAction {
  final Article focus;
  FocusArticleSelectedAction(this.focus);
}

class SetEditorDraftAction {
  final Article draft;
  SetEditorDraftAction(this.draft);
}
