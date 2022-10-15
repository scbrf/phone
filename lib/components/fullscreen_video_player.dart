import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:video_player/video_player.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController _controller;
  const FullscreenVideoPlayer(this._controller, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  var log = getLogger('_ArticleVideoPlayerState');
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          Navigator.of(context)
              .popUntil(ModalRoute.withName(ScbrfRoutes.articles));
        });
      }
      return GestureDetector(
        onTap: () {
          setState(() {
            widget._controller.value.isPlaying
                ? widget._controller.pause()
                : widget._controller.play();
          });
          log.d('video player tapped!');
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: widget._controller.value.aspectRatio,
            child: VideoPlayer(widget._controller),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
