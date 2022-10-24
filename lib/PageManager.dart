import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';

var log = getLogger('pageManager');

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<MediaItem>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();
  int lastPos = 0;

  // Events: Calls coming from the UI
  void init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final lastList = prefs.getString('playlist') ?? '[]';
    var playlist = jsonDecode(lastList);
    final mediaItems = List<MediaItem>.from(playlist
        .map<MediaItem>((song) => MediaItem(
              id: song['id'] ?? '',
              album: song['album'] ?? '',
              title: song['title'] ?? '',
              extras: {'url': song['url']},
            ))
        .toList());
    _audioHandler.addQueueItems(mediaItems);
    await Future.delayed(const Duration(milliseconds: 300));
    String? id = prefs.getString('playing');
    log.d("load playing id is $id");
    if (id != null) {
      for (int i = 0; i < playlist.length; i++) {
        if (id == playlist[i]['id']) {
          log.d('need skip to $i');
          _audioHandler.skipToQueueItem(i);
          await Future.delayed(const Duration(milliseconds: 100));
          break;
        }
      }
    }
  }

  savePlayList(List<MediaItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'playlist',
        jsonEncode(list
            .map<Map<String, dynamic>>((e) => {
                  "id": e.id,
                  "album": e.album,
                  "title": e.title,
                  "url": "${e.extras!['url']}",
                })
            .toList()));
  }

  savePosition(int pos) async {
    final mediaItem = _audioHandler.mediaItem.value;
    if (mediaItem != null && pos - lastPos > 5000) {
      log.d('save progress for item ${mediaItem.title} to $pos');
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('${mediaItem!.id}_pos', pos);
      lastPos = pos;
    }
  }

  savePlaylistFocus(id) async {
    if (id != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('playing', id);
    }
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
      } else {
        final newList = [...playlist];
        playlistNotifier.value = newList;
      }
      savePlayList(playlist);
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      log.d('process state change to $processingState');
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
      savePosition(position.inMilliseconds);
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
      log.d('progress change, ${progressNotifier.value}');
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
      log.d('progress change, ${progressNotifier.value}');
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
      _loadProgress();
      savePlaylistFocus(mediaItem?.id);
    });
  }

  void _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final mediaItem = _audioHandler.mediaItem.value;
    if (mediaItem != null) {
      int? pos = prefs.getInt('${mediaItem.id}_pos');
      lastPos = 0;
      log.d('load progress for item ${mediaItem.title} to $pos');
      if (pos != null) {
        _audioHandler.seek(Duration(milliseconds: pos));
      }
    }
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();
  void skipToItem(idx) => _audioHandler.skipToQueueItem(idx);
  void removeAtIdx(idx) => _audioHandler.removeQueueItemAt(idx);

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  Future<void> add(Map<String, String> song) async {
    final mediaItem = MediaItem(
      id: song['id'] ?? '',
      album: song['album'] ?? '',
      title: song['title'] ?? '',
      extras: {'url': song['url']},
    );
    _audioHandler.addQueueItem(mediaItem);
  }

  Future<void> insert(int idx, MediaItem e) async {
    _audioHandler.insertQueueItem(idx, e);
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}
