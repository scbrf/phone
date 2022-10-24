import 'dart:io';

import 'package:al_downloader/al_downloader.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:scbrf/PageManager.dart';
import 'package:scbrf/notifiers/play_button_notifier.dart';
import 'package:scbrf/notifiers/progress_notifier.dart';
import 'package:scbrf/services/service_locator.dart';
import 'package:scbrf/utils/logger.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  var log = getLogger('player');
  replaceWithLocal(
      List<MediaItem> list, String playing, ButtonState state) async {
    for (int i = 0; i < list.length; i++) {
      log.d("$playing is playing, skip...");
      if (list[i].title == playing && state != ButtonState.paused) continue;
      String url = list[i].extras!['url'];
      if (url.startsWith('http://')) {
        final status = ALDownloader.getDownloadStatusForUrl(url);
        if (status == ALDownloaderStatus.succeeded) {
          var local = await ALDownloaderPersistentFileManager
              .lazyGetALDownloaderPathModelForUrl(url);
          var item = list[i];
          item.extras!['url'] = 'file://${local.filePath}';
          getIt<PageManager>().removeAtIdx(i);
          getIt<PageManager>().insert(i, item);
          break; //一次只修改一个
        } else if (state == ALDownloaderStatus.unstarted) {
          startDownload(url);
        }
      }
    }
  }

  startDownload(url) {
    ALDownloader.download(url,
        downloaderHandlerInterface: ALDownloaderHandlerInterface(
          succeededHandler: () async {
            setState(() {});
          },
          progressHandler: (_) {
            setState(() {});
          },
          failedHandler: () {
            setState(() {});
          },
          pausedHandler: () {
            setState(() {});
          },
        ));
  }

  removeMediaItem(list, playing, e) async {
    var idx = list.indexOf(e);
    if (e.title == playing) {
      getIt<PageManager>().stop();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    getIt<PageManager>().removeAtIdx(idx);
    String url = e.extras!['url'];
    if (url.startsWith('http://')) {
      ALDownloader.cancel(url);
    } else {
      try {
        File(url).delete();
      } catch (ex) {
        log.e('error on delete file $url', ex);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pm = getIt<PageManager>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scarborough Podcast Player'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<ButtonState>(
              valueListenable: pm.playButtonNotifier,
              builder: (_, playState, __) => ValueListenableBuilder(
                valueListenable: pm.currentSongTitleNotifier,
                builder: (context, playing, child) => ValueListenableBuilder(
                  valueListenable: pm.playlistNotifier,
                  builder: (context, list, child) {
                    replaceWithLocal(list, playing, playState);
                    return ReorderableListView(
                        onReorder: (oldIndex, newIndex) async {
                          log.d('reorder from $oldIndex to $newIndex');
                          var item = list[oldIndex];
                          if (newIndex > oldIndex) {
                            getIt<PageManager>().removeAtIdx(oldIndex);
                            getIt<PageManager>().insert(newIndex - 1, item);
                          } else {
                            getIt<PageManager>().removeAtIdx(oldIndex);
                            getIt<PageManager>().insert(newIndex, item);
                          }
                        },
                        children: list.map<Widget>(
                          (e) {
                            String url = e.extras!['url'];
                            bool isLocal = !url.startsWith('http://');
                            ALDownloaderStatus? status;
                            if (!isLocal) {
                              status =
                                  ALDownloader.getDownloadStatusForUrl(url);
                              log.d('download status for url $url is $status');
                            }
                            return Dismissible(
                              key: ValueKey(e),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          'Delete',
                                          style: Theme.of(context)
                                              .textTheme
                                              .button!
                                              .copyWith(color: Colors.white),
                                        ),
                                      )
                                    ]),
                              ),
                              confirmDismiss: (direction) async {
                                await removeMediaItem(list, playing, e);
                                return true;
                              },
                              child: ListTile(
                                title: Text(e.title),
                                onTap: () {
                                  int myIdx = list.indexOf(e);
                                  getIt<PageManager>().skipToItem(myIdx);
                                },
                                selected: playing == e.title,
                                leading: const Icon(Icons.queue_music_outlined),
                                trailing: status == ALDownloaderStatus.succeeded
                                    ? const Icon(Icons.offline_pin_outlined)
                                    : status == ALDownloaderStatus.downloading
                                        ? const Icon(Icons.downloading)
                                        : isLocal
                                            ? null
                                            : GestureDetector(
                                                onTap: (() {
                                                  startDownload(
                                                      e.extras!['url']);
                                                  setState(() {});
                                                }),
                                                child:
                                                    const Icon(Icons.download),
                                              ),
                              ),
                            );
                          },
                        ).toList());
                  },
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: AudioProgressBar(),
          ),
          const AudioControlButtons()
        ],
      ),
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
        ],
      ),
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}
