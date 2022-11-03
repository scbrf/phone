import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/FloatPlayBtn.dart';
import 'package:scbrf/components/fullscreen_video_player.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/models/vc_store.dart';
import 'package:scbrf/utils/api.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';

class WebviewScreen extends StatefulWidget {
  final Article article;
  const WebviewScreen(this.article, {Key? key}) : super(key: key);
  @override
  WebviewScreenState createState() => WebviewScreenState();
}

class WebviewScreenState extends State<WebviewScreen> {
  WebViewController? controller;
  bool loading = true;
  var log = getLogger('weview');

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    injectEthereum(url) {
      String address = StoreProvider.of<AppState>(context).state.address;
      log.d('inject script, address is $address');
      controller!.runJavascript("""(()=>{
  let resolves={}
  console.log('start inject ethereum ...');
  window.ethereum = {
      address: '$address',
      isScarborough: true,
      isMobile: true,
      on(msg, cb) {
        if (msg === 'accountsChanged') {
          cb(['$address'])
        }
      },
      async request(req) {
        console.log('ethereum request called', JSON.stringify(req));
        if (req.method === 'eth_requestAccounts') {
          return ['$address'];
        }
        const requestid = new Date().getTime() + Math.random()
        return await new Promise(resolve=>{
          resolves[requestid] = resolve;
          req.requestid = requestid
          ipc.postMessage(JSON.stringify({...req, requestid}))
        })
      }
  }
  window.ipcResolve = ({requestid, data}) => {
    resolves[requestid](data)
  }
})()""");
    }

    webReply(String obj) {
      controller!.runJavascript('ipcResolve($obj)');
    }

    runWebInvoke(param) async {
      String host = StoreProvider.of<AppState>(context).state.currentStation;
      var client = http.Client();
      try {
        var response = await client.post(Uri.http(host, '/ipc'),
            headers: {"Content-type": "application/json"}, body: param);
        String body = utf8.decode(response.bodyBytes);
        log.d("request api $param get response $body");
        webReply(body);
      } finally {
        client.close();
      }
    }

    return OrientationBuilder(builder: (context, orientation) {
      log.d('orientation change to $orientation');
      if (orientation == Orientation.landscape &&
          widget.article.videoFilename.isNotEmpty) {
        VideoControllers.singleton.get(widget.article, 'fullscreen Player');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                FullscreenVideoPlayer(widget.article),
          ));
        });
      }
      return Scaffold(
        floatingActionButton: const FloatPlayBtn(),
        body: SafeArea(
          child: Column(
            children: [
              ...widget.article.videoFilename.isEmpty
                  ? []
                  : [ArticleVideoPlayer(widget.article)],
              Expanded(
                child: Stack(
                  children: [
                    WebView(
                      key: const ValueKey('webview'),
                      initialUrl:
                          "${widget.article.url}?seed=${DateTime.now().millisecondsSinceEpoch}",
                      allowsInlineMediaPlayback: true,
                      onWebViewCreated: (c) {
                        controller = c;
                      },
                      javascriptChannels: <JavascriptChannel>{
                        JavascriptChannel(
                          name: 'scbrf',
                          onMessageReceived: (JavascriptMessage message) async {
                            injectEthereum('');
                          },
                        ),
                        JavascriptChannel(
                          name: 'ipc',
                          onMessageReceived: (JavascriptMessage message) async {
                            log.d('receive from web ${message.message}');
                            runWebInvoke(message.message);
                          },
                        )
                      },
                      userAgent: 'Planet/MobileJS',
                      debuggingEnabled: true,
                      onProgress: (progress) {
                        log.d('loading webpage $progress');
                        if (loading && progress >= 60) {
                          loading = false;
                          setState(() {});
                        }
                      },
                      onPageStarted: injectEthereum,
                      onPageFinished: (url) async {
                        if (!widget.article.read && !widget.article.editable) {
                          StoreProvider.of<AppState>(context).dispatch(
                              MarkArticleReadedAction(
                                  widget.article.planetid, widget.article.id));
                        }
                        await controller!.runJavascript("""
                    if (document.querySelector('.video-container')){
                      document.querySelector('.video-container').style.display = 'none';
                    }
                  """);
                      },
                      javascriptMode: JavascriptMode.unrestricted,
                    ),
                    ...loading
                        ? [
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          ]
                        : []
                  ],
                ),
              )
            ],
          ),
        ),
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
  String videoPlayError = '';
  @override
  void initState() {
    super.initState();
    _controller = VideoControllers.singleton.get(widget.article, src);
    if (!_controller.value.isInitialized) {
      _controller.initialize().then((_) async {
        log.d(
            'video init done, need set state ${widget.article.videoFilename}');
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});

        if (widget.listenner != null) {
          _controller.addListener(() {
            widget.listenner!(_controller, widget.article);
          });
        }
      }).catchError((err) {
        setState(() {
          videoPlayError = '$err';
        });
        log.e(
            'play video ${widget.article.videoFilename} meet error $err ', err);
      });
    }
  }

  @override
  void dispose() {
    VideoControllers.singleton.dispose(widget.article, src);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log.d(
        'rebuild vide player widget ${widget.article.videoFilename} ${_controller.value.isInitialized}');
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
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    Container(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GestureDetector(
                            onTap: () async {
                              var messager = ScaffoldMessenger.of(context);
                              var rsp = await api('/dlna/list', {});
                              log.d('got devices: $rsp');
                              if (rsp['devices'] != null &&
                                  rsp['devices'].length > 0) {
                                String? device = await showModalBottomSheet<
                                        String>(
                                    context: context,
                                    builder: ((context) => SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: ListView.separated(
                                                itemBuilder: ((context,
                                                        index) =>
                                                    ListTile(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(rsp['devices']
                                                                    [index]
                                                                ['name']);
                                                      },
                                                      title: Text(
                                                        rsp['devices'][index]
                                                            ['name'],
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )),
                                                separatorBuilder: (context,
                                                        index) =>
                                                    const Divider(height: 1),
                                                itemCount:
                                                    rsp['devices'].length),
                                          ),
                                        )));
                                log.d('user select device $device');
                                if (device != null) {
                                  api('/dlna/play', {
                                    "device": device,
                                    "url": _controller.dataSource
                                  });
                                }
                              } else {
                                messager.showSnackBar(const SnackBar(
                                    content: Text("no devices found!")));
                              }
                            },
                            child: const Icon(
                              Icons.share_rounded,
                              size: 20,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                )),
          )
        : AspectRatio(
            aspectRatio: 16.0 / 9,
            child: Center(
              child: videoPlayError.isEmpty
                  ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.grey.shade400,
                      size: 30,
                    )
                  : Text(videoPlayError),
            ),
          );
  }
}
