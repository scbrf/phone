import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/screens/home.dart';
import 'package:scbrf/actions/actions.dart';

class ScbrfApp extends StatelessWidget {
  final Store<AppState> store;

  const ScbrfApp(
    this.store, {
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        routes: {
          ScbrfRoutes.home: (context) {
            onInit() {
              StoreProvider.of<AppState>(context).dispatch(FindStationAction());
            }

            return HomeScreen(
              onInit,
            );
          },
        },
      ),
    );
  }
}
