import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/PageManager.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/Avatar.dart';
import 'package:scbrf/components/create_planet_dialog.dart';
import 'package:scbrf/components/FloatPlayBtn.dart';
import 'package:scbrf/components/FollowingPlanetDialog.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/selectors/selectors.dart';
import 'package:scbrf/services/service_locator.dart';
import 'package:scbrf/utils/api.dart';
import 'package:scbrf/utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var log = getLogger('root');
  var deleted = [];
  Map<String, bool> textIcon = {};
  final ImagePicker _picker = ImagePicker();

  changePlanetAvatar(ctx, Planet p) async {
    var store = StoreProvider.of<AppState>(ctx);
    XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 250,
      maxHeight: 250,
      imageQuality: 80,
    );
    if (file == null) return;
    await api('/planet/avatar',
        {"id": p.id, "avatar": base64.encode(await file.readAsBytes())});
    store.dispatch(RefreshStationAction(route: false));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        distinct: true,
        converter: (Store<AppState> store) => store.state,
        builder: (ctx, state) {
          return ValueListenableBuilder<List<String>>(
            valueListenable: getIt<PageManager>().playlistNotifier,
            builder: (context, playlist, child) => Scaffold(
              appBar: AppBar(
                centerTitle: false,
                title: const Text('Scarborough'),
                actions: [
                  ...playlist.isEmpty
                      ? []
                      : [
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(ScbrfRoutes.musicPlayer);
                              },
                              child: const Icon(
                                Icons.queue_music_outlined,
                                size: 26.0,
                              ),
                            ),
                          ),
                        ],
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx2) => CreatePlanetDialog(() {
                            Navigator.of(ctx2).pop();
                            StoreProvider.of<AppState>(context)
                                .dispatch(RefreshStationAction());
                          }),
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        size: 26.0,
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx2) => FollowingPlanetDialog(() {
                              Navigator.of(ctx2).pop();
                              StoreProvider.of<AppState>(context)
                                  .dispatch(RefreshStationAction());
                            }),
                          );
                        },
                        child: const Icon(
                          Icons.group_add,
                          size: 26.0,
                        ),
                      )),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Text(
                              'Smart Feeds',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          ...ListTile.divideTiles(
                            context: context,
                            tiles: [
                              ListTile(
                                onTap: () {
                                  StoreProvider.of<AppState>(context).dispatch(
                                      FocusPlanetSelectedAction("fair"));
                                },
                                leading: const Icon(Icons.newspaper_outlined),
                                title: const Text('Fair'),
                                trailing: numberSelector(state)["fair"] == 0
                                    ? null
                                    : Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.orange[800],
                                            shape: BoxShape.circle),
                                        child: Center(
                                          child: Text(
                                            '${numberSelector(state)["fair"]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .button!
                                                .copyWith(color: Colors.white),
                                          ),
                                        )),
                              ),
                              ListTile(
                                onTap: () {
                                  StoreProvider.of<AppState>(context).dispatch(
                                      FocusPlanetSelectedAction("today"));
                                },
                                leading: const Icon(Icons.sunny),
                                title: const Text('Today'),
                                trailing: numberSelector(state)["today"] == 0
                                    ? null
                                    : Text('${numberSelector(state)["today"]}'),
                              ),
                              ListTile(
                                onTap: () {
                                  StoreProvider.of<AppState>(context).dispatch(
                                      FocusPlanetSelectedAction("unread"));
                                },
                                leading: const Icon(Icons.check_circle_outline),
                                title: const Text('Unread'),
                                trailing: numberSelector(state)["unread"] == 0
                                    ? null
                                    : Text(
                                        '${numberSelector(state)["unread"]}'),
                              ),
                              ListTile(
                                onTap: () {
                                  StoreProvider.of<AppState>(context).dispatch(
                                      FocusPlanetSelectedAction("starred"));
                                },
                                leading: const Icon(Icons.star_border),
                                title: const Text('Starred'),
                                trailing: numberSelector(state)["starred"] == 0
                                    ? null
                                    : Text(
                                        '${numberSelector(state)["starred"]}'),
                              ),
                            ],
                          ).toList(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Text(
                              'My Planets',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          ...ListTile.divideTiles(
                            context: context,
                            tiles: state.planets
                                .where(
                                    (element) => !deleted.contains(element.id))
                                .map(
                                  (e) => Dismissible(
                                    key: ValueKey(e.id),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (direction) async {
                                      return await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm"),
                                            content: const Text(
                                                "Would you like to delete this planet?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("Cancel"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Continue"),
                                                onPressed: () async {
                                                  var navigator =
                                                      Navigator.of(context);
                                                  var messager =
                                                      ScaffoldMessenger.of(
                                                          context);
                                                  var rsp = await api(
                                                      "/planet/delete", {
                                                    "id": e.id,
                                                  });
                                                  if ("${rsp['error']}"
                                                      .isEmpty) {
                                                    navigator.pop(true);
                                                  } else {
                                                    navigator.pop(false);
                                                    messager.showSnackBar(SnackBar(
                                                        content: Text(
                                                            "${rsp['error']}")));
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    background: Container(
                                      color: Colors.red,
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(
                                                'Delete',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .button!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            )
                                          ]),
                                    ),
                                    onDismissed: (direction) {
                                      log.d('deleted through $direction');
                                      setState(() {
                                        deleted.add(e.id);
                                      });
                                    },
                                    child: ListTile(
                                      onTap: () {
                                        StoreProvider.of<AppState>(context)
                                            .dispatch(FocusPlanetSelectedAction(
                                                "my:${e.id}"));
                                      },
                                      onLongPress: () {
                                        showDialog(
                                            context: context,
                                            builder: ((dialogCtx) {
                                              return AlertDialog(
                                                title: const Text("Confirm"),
                                                content: const Text(
                                                    "What action you want to take to this planet?"),
                                                actions: [
                                                  TextButton(
                                                    child: const Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.of(dialogCtx)
                                                          .pop(false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text("Avatar"),
                                                    onPressed: () async {
                                                      Navigator.of(dialogCtx)
                                                          .pop(false);
                                                      changePlanetAvatar(
                                                          context, e);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text("Edit"),
                                                    onPressed: () async {
                                                      Navigator.of(dialogCtx)
                                                          .pop();
                                                      showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            CreatePlanetDialog(
                                                          () {
                                                            Navigator.of(ctx)
                                                                .pop();
                                                            StoreProvider.of<
                                                                        AppState>(
                                                                    context)
                                                                .dispatch(
                                                                    RefreshStationAction(
                                                                        route:
                                                                            false));
                                                          },
                                                          planet: e,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              );
                                            }));
                                      },
                                      leading: Avatar(
                                          e.avatar.isEmpty
                                              ? ""
                                              : "${state.ipfsGateway}/ipns/${e.ipns}/avatar.png",
                                          e.name),
                                      title: Text(e.name),
                                    ),
                                  ),
                                ),
                          ).toList(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            child: Text(
                              'Following Planets',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          ...ListTile.divideTiles(
                            context: context,
                            tiles: state.following
                                .where(
                                    (element) => !deleted.contains(element.id))
                                .map((e) => Dismissible(
                                      key: ValueKey(e.id),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (direction) async {
                                        return await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Confirm"),
                                              content: const Text(
                                                  "Would you like to unfollow this planet?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("Continue"),
                                                  onPressed: () async {
                                                    var navigator =
                                                        Navigator.of(context);
                                                    var messager =
                                                        ScaffoldMessenger.of(
                                                            context);
                                                    var rsp = await api(
                                                        "/planet/unfollow",
                                                        {"id": e.id});
                                                    if ("${rsp['error']}"
                                                        .isEmpty) {
                                                      navigator.pop(true);
                                                    } else {
                                                      navigator.pop(false);
                                                      messager.showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  "${rsp['error']}")));
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(
                                                  'Delete',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .button!
                                                      .copyWith(
                                                          color: Colors.white),
                                                ),
                                              )
                                            ]),
                                      ),
                                      onDismissed: (direction) {
                                        log.d('deleted through $direction');
                                        setState(() {
                                          deleted.add(e.id);
                                        });
                                      },
                                      child: ListTile(
                                        onTap: () {
                                          StoreProvider.of<AppState>(context)
                                              .dispatch(
                                                  FocusPlanetSelectedAction(
                                                      "following:${e.id}"));
                                        },
                                        leading: Avatar(
                                            e.avatar.isEmpty
                                                ? ""
                                                : "${state.ipfsGateway}/ipfs/${e.cid}/avatar.png",
                                            e.name),
                                        title: Text(e.name),
                                        trailing: numberSelector(state)[
                                                    "following:${e.id}"] ==
                                                0
                                            ? null
                                            : Text(
                                                '${numberSelector(state)["following:${e.id}"]}'),
                                      ),
                                    )),
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Text(
                      'from ${state.currentStation}',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
