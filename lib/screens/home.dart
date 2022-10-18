import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/router.dart';

class LoadingScreen extends StatefulWidget {
  final void Function() onInit;
  const LoadingScreen(this.onInit, {Key? key}) : super(key: key);
  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, LoadState>(
      distinct: true,
      converter: (Store<AppState> store) => store.state.state,
      builder: (ctx, state) {
        return Scaffold(
          body: state.isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: const CircularProgressIndicator(),
                      ),
                      Text(
                        state.progress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error.isEmpty ? '没有找到任何站点' : state.error,
                          style: Theme.of(context).textTheme.labelMedium),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(ScbrfRoutes.scan);
                          },
                          child: const Text('扫码'),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(ScbrfRoutes.musicPlayer);
                          },
                          child: const Text('播客离线播放'),
                        ),
                      )
                    ],
                  ),
                ),
        );
      },
    );
  }
}
