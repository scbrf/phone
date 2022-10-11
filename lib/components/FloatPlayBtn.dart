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
  play(PageManager pm, List<String> playlist, String title,
      Article article) async {
    log.d('need play $title $playlist ${article.title}');
    if (title.isEmpty && playlist.isEmpty) {
      pm.add({
        'id': article.id,
        'title': article.title,
        'url': "${article.url}${article.audioFilename}"
      });
      await Future.delayed(const Duration(milliseconds: 100));
      pm.play();
    } else if (!playlist.contains(article.title)) {
      pm.add({
        'id': article.id,
        'title': article.title,
        'url': "${article.url}${article.audioFilename}"
      });
      await Future.delayed(const Duration(milliseconds: 100));
      pm.next();
      await Future.delayed(const Duration(milliseconds: 100));
      pm.play();
    } else {
      pm.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    log.d('build function callled for float play btn');
    final pageManager = getIt<PageManager>();
    return StoreConnector<AppState, Article>(
        distinct: true,
        converter: (Store<AppState> store) => store.state.focus,
        builder: (ctx, article) {
          return ValueListenableBuilder<List<String>>(
            valueListenable: pageManager.playlistNotifier,
            builder: (context, playlist, child) => ValueListenableBuilder(
              valueListenable: pageManager.currentSongTitleNotifier,
              builder: (context, title, child) =>
                  ValueListenableBuilder<ButtonState>(
                valueListenable: pageManager.playButtonNotifier,
                builder: ((context, btnState, child) {
                  if (article.audioFilename.isEmpty && title.isEmpty) {
                    return const SizedBox();
                  }
                  switch (btnState) {
                    case ButtonState.loading:
                      return FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: Colors.green,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ));
                    case ButtonState.paused:
                      return FloatingActionButton(
                          onPressed: () {
                            play(pageManager, playlist, title, article);
                          },
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.play_arrow));
                    case ButtonState.playing:
                      return FloatingActionButton(
                          onPressed: () {
                            pageManager.pause();
                          },
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.pause));
                  }
                }),
              ),
            ),
          );
        });
  }
}
