import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/FloatPlayBtn.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({Key? key}) : super(key: key);
  @override
  PreviewScreenState createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  WebViewController? controller;
  var log = getLogger('weview');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Article>(
      distinct: true,
      converter: (Store<AppState> store) => store.state.draft,
      builder: (ctx, draft) => Scaffold(
        floatingActionButton: const FloatPlayBtn(),
        body: SafeArea(
          child: WebView(
            key: const ValueKey('webview'),
            onWebViewCreated: (c) async {
              c.loadFile(await draft.getDraftPreviewPath());
            },
            userAgent: 'Planet/MobileJS',
            debuggingEnabled: true,
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
