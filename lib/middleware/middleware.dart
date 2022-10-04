import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';

List<Middleware<AppState>> createMiddleware() {
  return [
    TypedMiddleware<AppState, FindStationAction>(findStation),
  ];
}

findStation(Store<AppState> store, action, NextDispatcher next) {}
