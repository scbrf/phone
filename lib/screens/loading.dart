import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/models/models.dart';

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
        return state.isLoading
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
            : state.error.isNotEmpty
                ? Center(child: Text(state.error))
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('Scarborough'),
                    ),
                    body: const Center(
                      child: Text('home'),
                    ),
                  );
      },
    );
  }
}
