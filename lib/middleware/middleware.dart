import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/utils/api.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
// import 'package:nsd/nsd.dart';

final log = getLogger('middleware');
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

List<Middleware<AppState>> createMiddleware() {
  return [
    logger,
    TypedMiddleware<AppState, FindStationAction>(findStation),
    TypedMiddleware<AppState, CurrentStationSelectedAction>(saveLastStation),
    TypedMiddleware<AppState, CurrentStationSelectedAction>(loadStation),
    TypedMiddleware<AppState, RefreshStationAction>(loadStation),
    TypedMiddleware<AppState, CurrentStationSelectedAction>(setApiEntry),
    TypedMiddleware<AppState, MarkArticleReadedAction>(checkAndMarkReaded),
    TypedMiddleware<AppState, SetEditorDraftAction>(_saveDraft),
    TypedMiddleware<AppState, DraftTitleChangeAction>(_saveDraft),
    TypedMiddleware<AppState, DraftContentChangeAction>(_saveDraft),
    TypedMiddleware<AppState, FocusPlanetSelectedAction>(
        ((store, action, next) {
      next(action);
      navigatorKey.currentState!.pushNamed(ScbrfRoutes.articles);
    })),
    TypedMiddleware<AppState, FocusArticleSelectedAction>(
        ((store, action, next) async {
      next(action);
      navigatorKey.currentState!.pushNamed(ScbrfRoutes.webiew);
    })),
  ];
}

_saveDraft(Store<AppState> store, action, NextDispatcher next) async {
  next(action);
  if (store.state.draft.id.isEmpty) {
    var uuid = const Uuid();
    String id = uuid.v4().toUpperCase();
    store.dispatch(SetEditorDraftAction(store.state.draft.copyWith(id: id)));
  }
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  String draftPath = path.join(appDocPath, 'Drafts', store.state.draft.id);
  Directory draftDir = Directory(draftPath);
  if (!draftDir.existsSync()) {
    await draftDir.create(recursive: true);
  }
  String draftFilePath = path.join(draftPath, 'draft.json');
  File draftFile = File(draftFilePath);
  await draftFile.writeAsString(jsonEncode(store.state.draft.toJson()));
}

checkAndMarkReaded(Store<AppState> store, MarkArticleReadedAction action,
    NextDispatcher next) async {
  next(action);
  //mark as readed
  var rsp = await api('/article/markreaded', {
    "planetid": action.planetid,
    "articleid": action.articleid,
  });
  if ((rsp['error'] as String).isEmpty) {
    log.d('mark read succ!');
    store.dispatch(
        MarkArticleReadedSuccAction(action.planetid, action.articleid));
  } else {
    log.d('mark read error, reason: ${rsp['error']} !');
  }
}

logger(Store<AppState> store, action, NextDispatcher next) {
  next(action);
  log.d("action: $action appstate: ${store.state}");
}

saveLastStation(Store<AppState> store, CurrentStationSelectedAction action,
    NextDispatcher next) async {
  next(action);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_station', action.currentStation);
}

setApiEntry(Store<AppState> store, CurrentStationSelectedAction action,
    NextDispatcher next) async {
  next(action);
  apiEntry = action.currentStation;
}

Future<String?> loadLastStation() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('last_station');
}

loadStation(Store<AppState> store, action, NextDispatcher next) async {
  next(action);
  var client = http.Client();
  try {
    log.d('try to load station from ${store.state.currentStation}');
    var response = await client
        .post(Uri.http(store.state.currentStation, '/site'), body: {});
    String body = utf8.decode(response.bodyBytes);
    var mapBody = jsonDecode(body) as Map;
    log.d('list site ${store.state.currentStation} got $body');
    store.dispatch(
      StationLoadedAction(mapBody['address'],
          following: (mapBody['following'] as List)
              .map<FollowingPlanet>((json) => FollowingPlanet.fromJson(json))
              .toList(),
          planets: (mapBody['planets'] as List)
              .map<Planet>((json) => Planet.fromJson(json))
              .toList(),
          ipfsPeers: mapBody['ipfspeers'],
          ipfsGateway: mapBody['ipfsGateway']),
    );
    navigatorKey.currentState!
        .pushNamedAndRemoveUntil(ScbrfRoutes.root, ((route) => false));
  } finally {
    client.close();
  }
}

findStation(Store<AppState> store, action, NextDispatcher next) async {
  next(action);
  const String name = '_scarborough-api._tcp';
  List<String> serverEntry = [];

  final MDnsClient client = MDnsClient();
  await client.start();
  await for (final SrvResourceRecord ptr
      in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(name))) {
    serverEntry.add("${ptr.target}:${ptr.port}");
  }
  client.stop();

  Set<String> result = serverEntry.toSet();
  log.d("service find done! $result");
  store.dispatch(StationFindedAction(result.toList()));
  if (result.length == 1) {
    store.dispatch(CurrentStationSelectedAction(result.first));
  }
}
