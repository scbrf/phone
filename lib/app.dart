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
        navigatorKey: navigatorKey,
        routes: {
          ScbrfRoutes.scan: (context) => const QrScanScreen(),
          ScbrfRoutes.webiew: (context) => const WebviewScreen(),
          ScbrfRoutes.articles: (context) => const ArticlesScreen(),
          ScbrfRoutes.root: (context) => const HomeScreen(),
          ScbrfRoutes.home: (context) => LoadingScreen(() {
                loadLastStation().then((value) {
                  if (value != null && value.isNotEmpty) {
                    StoreProvider.of<AppState>(context)
                        .dispatch(CurrentStationSelectedAction(value));
                  } else {
                    StoreProvider.of<AppState>(context)
                        .dispatch(FindStationAction());
                  }
                });
              }),
        },
      ),
    );
  }
}
