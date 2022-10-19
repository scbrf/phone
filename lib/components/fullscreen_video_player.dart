import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scbrf/models/article.dart';
import 'package:scbrf/models/vc_store.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final Article _article;
  const FullscreenVideoPlayer(this._article, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  var log = getLogger('_ArticleVideoPlayerState');
  static const src = "fullscreen Player";
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _controller = VideoControllers.singleton.get(widget._article, src);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          Navigator.of(context)
              .popUntil(ModalRoute.withName(ScbrfRoutes.webiew));
        });
      }
      return GestureDetector(
        onTap: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
          log.d('video player tapped!');
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    VideoControllers.singleton.dispose(widget._article, src);
    super.dispose();
  }
}
