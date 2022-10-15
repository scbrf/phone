import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/FloatPlayBtn.dart';
import 'package:scbrf/components/fullscreen_video_player.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/models/vc_store.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/selectors/selectors.dart';
import 'package:scbrf/utils/api.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:video_player/video_player.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({Key? key}) : super(key: key);
  @override
  ArticlesScreenState createState() => ArticlesScreenState();
}

formatDate(timestamp) {
  var fmt = DateFormat('yyyy-MM-dd hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return fmt.format(date);
}

class ArticlesScreenState extends State<ArticlesScreen> {
  var log = getLogger('ArticlesScreenState');
  List<String> deleted = [];
  Article? playingArticle;
  VideoPlayerController? playingController;

  Widget editableListTile(Article e) {
    return Dismissible(
        key: ValueKey(e.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm"),
                content: const Text("Would you like to delete this article?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text("Continue"),
                    onPressed: () async {
                      var navigator = Navigator.of(context);
                      var messager = ScaffoldMessenger.of(context);
                      var rsp = await api("/article/delete",
                          {"id": e.id, "planetid": e.planetid});
                      if ("${rsp['error']}".isEmpty) {
                        navigator.pop(true);
                      } else {
                        navigator.pop(false);
                        messager.showSnackBar(
                            SnackBar(content: Text("${rsp['error']}")));
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        background: Container(
          color: Colors.red,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
        onDismissed: (direction) {
          log.d('deleted through $direction');
          setState(() {
            deleted.add(e.id);
          });
        },
        child: listTile(e));
  }

  onVideoControllerEvent(
      VideoPlayerController controller, Article playing) async {
    if (mounted && MediaQuery.of(context).orientation != Orientation.portrait) {
      return;
    }
    if (!mounted) {
      if (controller.value.isPlaying) {
        await controller.pause();
      }
      return;
    }
    if (controller.value.isPlaying) {
      log.d('playing ${controller.dataSource}');
      if (playingController != null && controller != playingController) {
        await playingController!.pause();
      }
      playingArticle = playing;
      playingController = controller;
      SystemChrome.setPreferredOrientations([]);
    } else {
      log.d('stop playing ${controller.dataSource}');
      if (controller == playingController) {
        playingArticle = null;
        playingController = null;
      }
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  Widget listTile(Article e) {
    return ListTile(
      leading: !e.read && !e.editable
          ? Container(
              decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              width: 10,
              height: 10,
            )
          : e.starred
              ? const Icon(
                  Icons.star_border_outlined,
                  color: Colors.orangeAccent,
                )
              : const Icon(Icons.abc),
      isThreeLine: true,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          e.title,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(20, 3, 10, 3),
      minLeadingWidth: 20,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            //Summary
            e.summary.replaceAll("\n", ""),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          ...e.videoFilename.isEmpty
              ? []
              : [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    child: Hero(
                      tag: 'video_${e.id}',
                      child: ArticleVideoPlayer(
                        e,
                        listenner: onVideoControllerEvent,
                        key: ValueKey('video_${e.id}'),
                      ),
                    ),
                  )
                ],
          Container(
            // Datetime and icons
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Text(
                  '${formatDate(e.created)}',
                  style: Theme.of(context).textTheme.caption,
                ),
                ...e.audioFilename.isNotEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.volume_up_outlined,
                              size: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .fontSize),
                        )
                      ]
                    : [],
                ...e.videoFilename.isNotEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(Icons.video_camera_back_outlined,
                              size: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .fontSize),
                        )
                      ]
                    : [],
              ],
            ),
          ),
        ],
      ),
      onLongPress: () async {
        var store = StoreProvider.of<AppState>(context);
        StoreProvider.of<AppState>(context)
            .dispatch(FocusArticleSelectedAction(e));
        if (store.state.focusPlanet.startsWith("following:")) {
          //Follow的文章，弹出Star对话框
          //Editor article.
          bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm"),
                content:
                    const Text("Would you like to star/unstar this article?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text("Continue"),
                    onPressed: () async {
                      var navigator = Navigator.of(context);
                      navigator.pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (confirm) {
            store.dispatch(TriggerStarredArticleAction(e));
          }
        } else if (store.state.focusPlanet.startsWith('my:')) {
          //Editor article.
          bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm"),
                content: const Text("Would you like to edit this article?"),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text("Fair"),
                    onPressed: () async {
                      var navigator = Navigator.of(context);
                      navigator.pop(false);
                      navigator.pushNamed(ScbrfRoutes.fair);
                    },
                  ),
                  TextButton(
                    child: const Text("Continue"),
                    onPressed: () async {
                      var navigator = Navigator.of(context);
                      navigator.pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (confirm) {
            store.dispatch(EditArticleAction(e));
          }
        }
      },
      onTap: () {
        StoreProvider.of<AppState>(context)
            .dispatch(FocusArticleSelectedAction(e, doRoute: true));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      log.d('orientation change to $orientation');
      if (orientation == Orientation.landscape && playingArticle != null) {
        VideoControllers.singleton.get(playingArticle!, 'fullscreen Player');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                FullscreenVideoPlayer(playingArticle!),
          ));
        });
      }
      return StoreConnector<AppState, Articles>(
        distinct: true,
        converter: (Store<AppState> store) => articlesSelector(store.state),
        builder: (ctx, articles) {
          log.d('building articles screen');
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: Text(articles.title),
              actions: articles.focusPlanetId.startsWith('my:')
                  ? <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            onTap: () async {
                              StoreProvider.of<AppState>(context).dispatch(
                                  NewDraftAction(articles.focusPlanetId
                                      .substring('my:'.length)));
                            },
                            child: const Icon(
                              Icons.note_alt_outlined,
                              size: 26.0,
                            ),
                          )),
                    ]
                  : <Widget>[],
            ),
            floatingActionButton: const FloatPlayBtn(),
            body: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: articles.articles
                    .where((e) => !deleted.contains(e.id))
                    .map<Widget>((e) => articles.focusPlanetId.startsWith('my:')
                        ? editableListTile(e)
                        : listTile(e))
                    .toList(),
              ).toList(),
            ),
          );
        },
      );
    });
  }
}

class ArticleVideoPlayer extends StatefulWidget {
  final Article article;
  final Function? listenner;
  const ArticleVideoPlayer(this.article, {this.listenner, Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ArticleVideoPlayerState();
}

class _ArticleVideoPlayerState extends State<ArticleVideoPlayer> {
  late VideoPlayerController _controller;
  static const src = 'listtile';
  var log = getLogger('_ArticleVideoPlayerState');
  @override
  void initState() {
    super.initState();
    _controller = VideoControllers.singleton.get(widget.article, src);
    if (!_controller.value.isInitialized) {
      _controller.initialize().then((_) {
        setState(() {});
        if (widget.listenner != null) {
          _controller.addListener(() {
            widget.listenner!(_controller, widget.article);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
              log.d('video player tapped!');
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          )
        : AspectRatio(
            aspectRatio: 16.0 / 9,
            child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.grey.shade400,
                size: 30,
              ),
            ),
          );
  }

  @override
  void dispose() {
    VideoControllers.singleton.dispose(widget.article, src);
    super.dispose();
  }
}
