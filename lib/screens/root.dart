import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/Avatar.dart';
import 'package:scbrf/components/float_play_btn.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/selectors/selectors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Map<String, bool> textIcon = {};
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        distinct: true,
        converter: (Store<AppState> store) => store.state,
        builder: (ctx, state) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Scarborough'),
              ),
              floatingActionButton: const FloatPlayBtn(),
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
                            tiles: state.planets.map(
                              (e) => ListTile(
                                onTap: () {
                                  StoreProvider.of<AppState>(context).dispatch(
                                      FocusPlanetSelectedAction("my:${e.id}"));
                                },
                                leading: Avatar(
                                    e.avatar.isEmpty
                                        ? ""
                                        : "${state.ipfsGateway}/ipns/${e.ipns}/avatar.png",
                                    e.name),
                                title: Text(e.name),
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
                            tiles: state.following.map(
                              (e) => ListTile(
                                onTap: () {
                                  StoreProvider.of<AppState>(context).dispatch(
                                      FocusPlanetSelectedAction(
                                          "following:${e.id}"));
                                },
                                leading: Avatar(
                                    e.avatar.isEmpty
                                        ? ""
                                        : "${state.ipfsGateway}/ipfs/${e.cid}/avatar.png",
                                    e.name),
                                title: Text(e.name),
                                trailing: numberSelector(
                                            state)["following:${e.id}"] ==
                                        0
                                    ? null
                                    : Text(
                                        '${numberSelector(state)["following:${e.id}"]}'),
                              ),
                            ),
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
              ));
        });
  }
}
