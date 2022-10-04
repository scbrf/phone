import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/selectors/selectors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({Key? key}) : super(key: key);
  @override
  WebviewScreenState createState() => WebviewScreenState();
}

class WebviewScreenState extends State<WebviewScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Article>(
        distinct: true,
        converter: (Store<AppState> store) => store.state.focus,
        builder: (ctx, article) {
          return Scaffold(
            appBar: AppBar(
              title: Text(article.title),
            ),
            body: WebView(
              initialUrl: article.url,
            ),
          );
        });
  }
}
