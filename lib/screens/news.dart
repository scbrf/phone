import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/avatar.dart';
import 'package:scbrf/models/AppState.dart';
import 'package:scbrf/models/article.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/screens/screen.dart';
import 'package:scbrf/selectors/selectors.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => NewsState();
}

class NewsState extends State<NewsScreen> {
  final _scrollGroup = LinkedScrollControllerGroup();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scarborough'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(ScbrfRoutes.root);
                },
                child: const Icon(
                  Icons.holiday_village_outlined,
                  size: 26.0,
                ),
              ),
            )
          ],
        ),
        body: StoreConnector<AppState, List<List<Article>>>(
            builder: ((context, vm) => Row(
                  children: vm
                      .map((e) => Expanded(
                            child: SingleColumnArticles(e, _scrollGroup),
                          ))
                      .toList(),
                )),
            converter: (s) {
              double minW = min(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height);
              int columns =
                  (MediaQuery.of(context).size.width * 2 / minW).floor();
              return allFollowingArticles(s.state, columns);
            }));
  }
}

class SingleColumnArticles extends StatefulWidget {
  final List<Article> articles;
  final LinkedScrollControllerGroup scrollGroup;
  const SingleColumnArticles(this.articles, this.scrollGroup, {Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => SingleColumnArticlesState();
}

class SingleColumnArticlesState extends State<SingleColumnArticles> {
  ScrollController? scrollController;

  @override
  void initState() {
    scrollController = widget.scrollGroup.addAndGet();
    super.initState();
  }

  @override
  void dispose() {
    scrollController!.dispose();
    super.dispose();
  }

  String getImage(Article article) {
    for (String a in article.attachments) {
      if (a.endsWith('.png')) return a;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) => ListView.separated(
      controller: scrollController,
      itemBuilder: ((context, index) => ListTile(
          onTap: () {
            StoreProvider.of<AppState>(context)
                .dispatch(FocusArticleSelectedAction(widget.articles[index]));
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: ScbrfRoutes.webiew),
                builder: (BuildContext context) =>
                    WebviewScreen(widget.articles[index]),
              ),
            );
          },
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...getImage(widget.articles[index]).isNotEmpty
                  ? [
                      Image.network(
                          '${widget.articles[index].url}${getImage(widget.articles[index])}')
                    ]
                  : [],
              Text(
                widget.articles[index].title,
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              )
            ],
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Avatar(
                widget.articles[index].planet!.avatar.isEmpty
                    ? ""
                    : "${widget.articles[index].url}../avatar.png",
                widget.articles[index].planet!.name,
                size: Theme.of(context).textTheme.caption!.fontSize! / 2,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(widget.articles[index].planet!.name,
                    style: Theme.of(context).textTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              ...widget.articles[index].audioFilename.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.volume_up_outlined,
                            size:
                                Theme.of(context).textTheme.caption!.fontSize),
                      )
                    ]
                  : [],
              ...widget.articles[index].videoFilename.isNotEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(Icons.video_camera_back_outlined,
                            size:
                                Theme.of(context).textTheme.caption!.fontSize),
                      )
                    ]
                  : [],
              Text(widget.articles[index].pinState,
                  style: Theme.of(context).textTheme.caption)
            ],
          ))),
      separatorBuilder: ((context, index) => const Divider(
            height: 1,
          )),
      itemCount: widget.articles.length);
}
