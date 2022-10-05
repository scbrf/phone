import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/selectors/selectors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Smart Feeds',
                  style: Theme.of(context).textTheme.caption,
                ),
                ListTile(
                  onTap: () {
                    StoreProvider.of<AppState>(context)
                        .dispatch(FocusPlanetSelectedAction("today"));
                  },
                  leading: const Icon(Icons.sunny),
                  title: const Text('Today'),
                  trailing: numberSelector(state)["today"] == 0
                      ? null
                      : Text('${numberSelector(state)["today"]}'),
                ),
                ListTile(
                  onTap: () {
                    StoreProvider.of<AppState>(context)
                        .dispatch(FocusPlanetSelectedAction("unread"));
                  },
                  leading: const Icon(Icons.check_circle_outline),
                  title: const Text('Unread'),
                  trailing: numberSelector(state)["unread"] == 0
                      ? null
                      : Text('${numberSelector(state)["unread"]}'),
                ),
                ListTile(
                  onTap: () {
                    StoreProvider.of<AppState>(context)
                        .dispatch(FocusPlanetSelectedAction("starred"));
                  },
                  leading: const Icon(Icons.star_border),
                  title: const Text('Starred'),
                  trailing: numberSelector(state)["starred"] == 0
                      ? null
                      : Text('${numberSelector(state)["starred"]}'),
                ),
                Text(
                  'My Planets',
                  style: Theme.of(context).textTheme.caption,
                ),
                ...state.planets.map(
                  (e) => ListTile(
                    onTap: () {
                      StoreProvider.of<AppState>(context)
                          .dispatch(FocusPlanetSelectedAction("my:${e.id}"));
                    },
                    leading: CircleAvatar(
                        onBackgroundImageError: (exception, stackTrace) => {},
                        backgroundImage: NetworkImage(
                            "${state.ipfsGateway}/ipns/${e.ipns}/avatar.png"),
                        child: Text(e.name.substring(0, 1).toUpperCase())),
                    title: Text(e.name),
                  ),
                ),
                Text(
                  'Following Planets',
                  style: Theme.of(context).textTheme.caption,
                ),
                ...state.following.map((e) => ListTile(
                      onTap: () {
                        StoreProvider.of<AppState>(context).dispatch(
                            FocusPlanetSelectedAction("following:${e.id}"));
                      },
                      leading: CircleAvatar(
                          // onBackgroundImageError: (exception, stackTrace) => {},
                          // backgroundImage: NetworkImage(
                          //     "${state.ipfsGateway}/ipfs/${e.cid}/avatar.png"),
                          child: Text(e.name.substring(0, 1).toUpperCase())),
                      title: Text(e.name),
                      trailing: numberSelector(state)["following:${e.id}"] == 0
                          ? null
                          : Text(
                              '${numberSelector(state)["following:${e.id}"]}'),
                    ))
              ],
            ),
          );
        });
  }
}
