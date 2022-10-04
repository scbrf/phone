import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:redux_logging/redux_logging.dart';

List<Middleware<AppState>> createMiddleware() {
  return [
    LoggingMiddleware.printer(),
    TypedMiddleware<AppState, FindStationAction>(findStation),
  ];
}

findStation(Store<AppState> store, action, NextDispatcher next) {
  next(action);
}
