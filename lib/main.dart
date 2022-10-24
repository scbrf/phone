import 'dart:io';

import 'package:al_downloader/al_downloader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scbrf/app.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/reducers/reducers.dart';
import 'package:scbrf/middleware/middleware.dart';
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await setupServiceLocator();
    await ALDownloader.initialize();
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(ScbrfApp(
    Store<AppState>(
      appReducer,
      initialState: AppState.loading(),
      middleware: createMiddleware(),
    ),
  ));
}
