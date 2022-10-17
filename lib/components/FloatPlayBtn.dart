import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/models/AppState.dart';
import 'package:scbrf/models/article.dart';
import 'package:scbrf/notifiers/play_button_notifier.dart';
import 'package:scbrf/PageManager.dart';
import 'package:scbrf/services/service_locator.dart';
import 'package:scbrf/utils/logger.dart';

class FloatPlayBtn extends StatefulWidget {
  const FloatPlayBtn({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FloatBtnState();
}

class _FloatBtnState extends State<FloatPlayBtn> {
  var log = getLogger('floatPlayBtn');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Article>(
        converter: (Store<AppState> store) => store.state.focus,
        builder: (ctx, article) {
          return article.audioFilename.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () {
                    getIt<PageManager>().add({
                      'id': article.id,
                      'title': article.title,
                      'url': "${article.url}${article.audioFilename}"
                    });
                    getIt<PageManager>().play();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("audio file queued!")));
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                )
              : Container();
        });
  }
}
