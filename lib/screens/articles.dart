import 'package:flutter/material.dart';
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

class ArticlesScreenState extends State<ArticlesScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Articles>(
        distinct: true,
        converter: (Store<AppState> store) => articlesSelector(store.state),
        builder: (ctx, articles) {
          return Scaffold(
            appBar: AppBar(
              title: Text(articles.title),
            ),
            body: ListView(
              children: articles.articles
                  .map<ListTile>((e) => ListTile(
                        title: Text(e.title),
                        onTap: () {
                          StoreProvider.of<AppState>(context)
                              .dispatch(FocusArticleSelectedAction(e));
                        },
                      ))
                  .toList(),
            ),
          );
        });
  }
}
