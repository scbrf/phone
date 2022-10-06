import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/selectors/selectors.dart';

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
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Articles>(
        distinct: true,
        converter: (Store<AppState> store) => articlesSelector(store.state),
        builder: (ctx, articles) {
          log.d('building articles screen');
          return Scaffold(
            appBar: AppBar(
              title: Text(articles.title),
            ),
            body: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: articles.articles
                    .map<ListTile>((e) => ListTile(
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
                          onTap: () {
                            StoreProvider.of<AppState>(context)
                                .dispatch(FocusArticleSelectedAction(e));
                          },
                        ))
                    .toList(),
              ).toList(),
            ),
          );
        });
  }
}
