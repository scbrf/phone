import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/screens/screen.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/middleware/middleware.dart';

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
        initialRoute: ScbrfRoutes.loading,
        navigatorKey: navigatorKey,
        routes: {
          ScbrfRoutes.home: (context) => const HomeScreen(),
          ScbrfRoutes.loading: (context) {
            onInit() {
              StoreProvider.of<AppState>(context).dispatch(FindStationAction());
            }

            return LoadingScreen(
              onInit,
            );
          },
        },
      ),
    );
  }
}
