import 'dart:io';

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
    if (Platform.isAndroid || Platform.isIOS) {
      getIt<PageManager>().init();
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      getIt<PageManager>().dispose();
    }
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
          ScbrfRoutes.preview: (context) => const PreviewScreen(),
          ScbrfRoutes.publish: (context) => const PublishScreen(),
          ScbrfRoutes.articles: (context) => const ArticlesScreen(),
          ScbrfRoutes.fair: (context) => const FairRequestScreen(),
          ScbrfRoutes.root: (context) => const HomeScreen(),
          ScbrfRoutes.musicPlayer: (context) => const MusicPlayer(),
          ScbrfRoutes.news: (context) => const NewsScreen(),
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
