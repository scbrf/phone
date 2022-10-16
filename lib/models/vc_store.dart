import 'package:scbrf/models/article.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:video_player/video_player.dart';

class VCSource {
  final VideoPlayerController controller;
  final Set<String> src = {};
  final Article article;
  VCSource(this.article)
      : controller = VideoPlayerController.network(
            '${article.url}${Uri.encodeComponent(article.videoFilename)}');
}

class VideoControllers {
  var log = getLogger('VideoControllers');
  static var singleton = VideoControllers();
  final Map<String, VCSource> controllers = {};
  get(Article article, String src) {
    log.d('get ${article.id} ${article.videoFilename} $src');
    if (!controllers.containsKey(article.id)) {
      controllers[article.id] = VCSource(article);
      log.d(
          'load video from ${article.videoFilename} ${controllers[article.id]!.controller.dataSource}');
    }
    controllers[article.id]!.src.add(src);
    return controllers[article.id]!.controller;
  }

  dispose(Article article, String src) async {
    log.d('dispose ${article.id} $src');
    if (!controllers.containsKey(article.id) ||
        !controllers[article.id]!.src.contains(src)) {
      // throw 'invalid src $src';
      return;
    }
    controllers[article.id]!.src.remove(src);
    //just gives some delay, maybe it will reuse
    await Future.delayed(const Duration(seconds: 1));
    if (controllers.containsKey(article.id) &&
        controllers[article.id]!.src.isEmpty) {
      log.d('real dispose ${article.id} $src');
      controllers[article.id]!.controller.dispose();
      controllers.remove(article.id);
    }
  }
}
