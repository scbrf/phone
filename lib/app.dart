import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/PageManager.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/screens/screen.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/middleware/middleware.dart';

import 'services/service_locator.dart';

class ScbrfApp extends StatefulWidget {
  final Store<AppState> store;
  const ScbrfApp(
    this.store, {
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<ScbrfApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: widget.store,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        routes: {
          ScbrfRoutes.scan: (context) => const QrScanScreen(),
          ScbrfRoutes.webiew: (context) => const WebviewScreen(),
          ScbrfRoutes.articles: (context) => const ArticlesScreen(),
          ScbrfRoutes.root: (context) => const HomeScreen(),
          ScbrfRoutes.draft: (context) => DraftScreen(
              widget.store.state.draft.title, widget.store.state.draft.content),
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
