import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';
import 'package:scbrf/utils/api.dart';
import 'package:path/path.dart' as path;

class PublishScreen extends StatefulWidget {
  const PublishScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> {
  String progress = 'publish ...';
  bool allowBack = false;
  bool publishSucc = false;

  startPublish(Store<AppState> store) async {
    var rsp = await api('/draft/publish', store.state.draft.toJson());
    var draftBase = await store.state.draft.getDraftDir();
    if (rsp.containsKey('files')) {
      for (String file in rsp['files']) {
        setState(() {
          progress = 'uploading $file ...';
        });
        try {
          await upload(path.join(draftBase, file));
        } catch (ex) {
          setState(() {
            progress = ex.toString();
          });
        }
      }
      rsp = await api('/draft/publish', store.state.draft.toJson());
    }
    publishSucc = "${rsp["error"]}".isEmpty;
    if (publishSucc) {
      await store.state.draft.remove();
      store.dispatch(RefreshStationAction(route: false));
    }
    setState(() {
      progress = "${rsp["error"]}".isEmpty ? 'done!' : "${rsp["error"]}";
      allowBack = true;
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: (() async {
          if (!allowBack) return false;
          if (!publishSucc) {
            return true;
          }
          Navigator.of(context)
              .popUntil(ModalRoute.withName(ScbrfRoutes.articles));
          return false;
        }),
        child: StoreConnector<AppState, Article>(
          onInit: (store) {
            startPublish(store);
          },
          builder: ((context, draft) => Scaffold(
                appBar: AppBar(
                  title: const Text('Publishing'),
                  centerTitle: false,
                ),
                body: Center(child: Text(progress)),
              )),
          converter: ((store) => store.state.draft),
        ),
      );
}
