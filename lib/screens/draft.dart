import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/utils/logger.dart';

class DraftScreen extends StatefulWidget {
  final String title;
  final String content;
  const DraftScreen(this.title, this.content, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  var titleController = TextEditingController();
  var contentController = TextEditingController();
  var log = getLogger('draft screen state');
  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
    contentController.text = widget.content;
    log.d('init state content is ${widget.content}');
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Article>(
        distinct: true,
        converter: (Store<AppState> store) => store.state.draft,
        builder: (ctx, state) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Draft Editor'),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.image_outlined,
                        size: 26.0,
                      ),
                    ),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (item) {},
                    itemBuilder: (context) => [
                      const PopupMenuItem<int>(
                          value: 0, child: Text('Preview')),
                      const PopupMenuItem<int>(
                          value: 1, child: Text('Publish')),
                    ],
                  ),
                ],
              ),
              body: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                        ),
                        onChanged: (v) {
                          StoreProvider.of<AppState>(context)
                              .dispatch(DraftTitleChangeAction(v));
                        },
                      ),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                                hasScrollBody: false,
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: contentController,
                                        decoration: const InputDecoration(
                                          hintText: '千里之行，从第一个字开始...',
                                        ),
                                        maxLines: null,
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(height: 2),
                                        keyboardType: TextInputType.multiline,
                                        onChanged: (v) {
                                          StoreProvider.of<AppState>(context)
                                              .dispatch(
                                                  DraftContentChangeAction(v));
                                        },
                                      ),
                                    ),
                                    // Container(
                                    //   color: Colors.red,
                                    //   height: 20,
                                    // )
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ],
                  )));
        });
  }
}
