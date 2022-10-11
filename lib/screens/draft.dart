import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/app.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:path/path.dart' as path;

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
  final ImagePicker _picker = ImagePicker();

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
        builder: (ctx, draft) {
          return FutureBuilder<String>(
            future: draft.getDraftDir(),
            builder: ((context, snapshot) => !snapshot.hasData
                ? const SizedBox(width: 0, height: 0)
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('Draft Editor'),
                      centerTitle: false,
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            onTap: () async {
                              final store = StoreProvider.of<AppState>(context);
                              List<XFile> files = await _picker.pickMultiImage(
                                imageQuality: 80,
                              );
                              List<String> attachments = [];
                              for (var file in files) {
                                String draftPath = await draft.getDraftDir();
                                String attachPath =
                                    path.join(draftPath, file.name);
                                await file.saveTo(attachPath);
                                attachments.add(file.name);
                              }
                              store.dispatch(SetEditorDraftAction(
                                  draft.copyWith(attachments: attachments)));
                            },
                            child: const Icon(
                              Icons.image_outlined,
                              size: 26.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: GestureDetector(
                            onTap: () async {
                              final store = StoreProvider.of<AppState>(context);
                              XFile? file = await _picker.pickVideo(
                                source: ImageSource.gallery,
                              );
                              if (file != null) {
                                String draftPath = await draft.getDraftDir();
                                String attachPath =
                                    path.join(draftPath, file.name);
                                await file.saveTo(attachPath);
                                store.dispatch(SetEditorDraftAction(
                                    draft.copyWith(videoFilename: file.name)));
                              }
                            },
                            child: const Icon(
                              Icons.video_camera_back_outlined,
                              size: 26.0,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (item) async {
                            var navigator = Navigator.of(context);
                            if (item == 'preview') {
                              await draft.renderDraftPreview();
                              navigator.pushNamed(ScbrfRoutes.preview);
                            } else if (item == 'publish') {
                              // StoreProvider.of(context)
                              //     .dispatch(DraftPublishAction());
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                                value: 'preview', child: Text('Preview')),
                            const PopupMenuItem<String>(
                                value: 'publish', child: Text('Publish')),
                          ],
                        ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                          ...draft.videoFilename.isNotEmpty
                              ? [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Text(
                                      'videofile attached',
                                      textAlign: TextAlign.start,
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  )
                                ]
                              : [],
                          Expanded(
                            child: CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            keyboardType:
                                                TextInputType.multiline,
                                            onChanged: (v) {
                                              StoreProvider.of<AppState>(
                                                      context)
                                                  .dispatch(
                                                      DraftContentChangeAction(
                                                          v));
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: draft.attachments
                                                  .map(
                                                    (e) => GestureDetector(
                                                      onTap: () {
                                                        var selection =
                                                            contentController
                                                                .selection;
                                                        String newText =
                                                            contentController
                                                                .text
                                                                .replaceRange(
                                                                    selection
                                                                        .start,
                                                                    selection
                                                                        .end,
                                                                    '<img alt="$e" src="$e">');
                                                        contentController.text =
                                                            newText;
                                                      },
                                                      child: Image.file(
                                                        File(path.join(
                                                            snapshot.data!, e)),
                                                        width: 80,
                                                        height: 80,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          );
        });
  }
}
