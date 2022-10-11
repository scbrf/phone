import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/components/FloatPlayBtn.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/selectors/selectors.dart';
import 'package:scbrf/utils/api.dart';
import 'package:scbrf/utils/logger.dart';

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
  @override
  Widget build(BuildContext context) {
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
                    .map<Widget>(
                      (e) => Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Would you like to delete this article?"),
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
                                      var messager =
                                          ScaffoldMessenger.of(context);
                                      var rsp = await api("/article/delete",
                                          {"id": e.id, "planetid": e.planetid});
                                      if ("${rsp['error']}".isEmpty) {
                                        navigator.pop(true);
                                      } else {
                                        navigator.pop(false);
                                        messager.showSnackBar(SnackBar(
                                            content: Text("${rsp['error']}")));
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
                        onDismissed: (direction) {
                          log.d('deleted through $direction');
                          setState(() {
                            deleted.add(e.id);
                          });
                        },
                        child: ListTile(
                          leading: !e.read && !e.editable
                              ? Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  width: 10,
                                  height: 10,
                                )
                              : const Icon(Icons.abc),
                          isThreeLine: true,
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              e.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 3, 10, 3),
                          minLeadingWidth: 20,
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.summary.replaceAll("\n", ""),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      '${formatDate(e.created)}',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                    ...e.audioFilename.isNotEmpty
                                        ? [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Icon(
                                                  Icons.volume_up_outlined,
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
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Icon(
                                                  Icons
                                                      .video_camera_back_outlined,
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
                          onLongPress: () {
                            //Edit
                          },
                          onTap: () {
                            StoreProvider.of<AppState>(context)
                                .dispatch(FocusArticleSelectedAction(e));
                          },
                        ),
                      ),
                    )
                    .toList(),
              ).toList(),
            ),
          );
        });
  }
}
