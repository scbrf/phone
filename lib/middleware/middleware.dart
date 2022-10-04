import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:http/http.dart' as http;

final log = getLogger('middleware');
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

List<Middleware<AppState>> createMiddleware() {
  return [
    logger,
    TypedMiddleware<AppState, FindStationAction>(findStation),
    TypedMiddleware<AppState, CurrentStationSelectedAction>(loadStation),
    TypedMiddleware<AppState, FocusPlanetSelectedAction>(
        ((store, action, next) {
      next(action);
      navigatorKey.currentState!.pushNamed(ScbrfRoutes.articles);
    })),
  ];
}

logger(Store<AppState> store, action, NextDispatcher next) {
  next(action);
  log.d("action: $action appstate: ${store.state}");
}

loadStation(Store<AppState> store, action, NextDispatcher next) async {
  next(action);
  var client = http.Client();
  try {
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
        .pushNamedAndRemoveUntil(ScbrfRoutes.home, ((route) => false));
  } finally {
    client.close();
  }
}

findStation(Store<AppState> store, action, NextDispatcher next) async {
  next(action);
  const String name = '_api._scarborough._tcp.local';
  final MDnsClient client = MDnsClient();
  await client.start();

  List<String> serverEntry = [];
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
