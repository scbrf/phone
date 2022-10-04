import 'package:flutter/material.dart';
import 'package:scbrf/app.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/reducers/reducers.dart';
import 'package:scbrf/middleware/middleware.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ScbrfApp(
    Store<AppState>(
      appReducer,
      initialState: AppState.loading(),
      middleware: createMiddleware(),
    ),
  ));
}
