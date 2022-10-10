import 'package:flutter/material.dart';
import 'package:scbrf/utils/api.dart';

class FollowingPlanetDialog extends StatefulWidget {
  final VoidCallback onSucc;
  const FollowingPlanetDialog(this.onSucc, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FollowingPlanetState();
}

class _FollowingPlanetState extends State<FollowingPlanetDialog> {
  String link = '';
  bool following = false;
  String error = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Follow Planet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            onChanged: (v) {
              setState(() {
                link = v;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Name',
            ),
          ),
          ...following
              ? [const Center(child: CircularProgressIndicator())]
              : [],
          ...error.isEmpty
              ? []
              : [
                  Text(
                    error,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.red),
                  )
                ]
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: link.isEmpty || following
              ? null
              : () async {
                  setState(
                    () {
                      following = true;
                    },
                  );
                  var rsp = await api('/planet/follow', {
                    "follow": link,
                  });
                  if ((rsp['error'] as String).isEmpty) {
                    widget.onSucc();
                  } else {
                    setState(() {
                      error = rsp['error'];
                      following = false;
                    });
                  }
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
