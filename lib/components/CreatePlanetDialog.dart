import 'package:flutter/material.dart';
import 'package:scbrf/utils/api.dart';

class CreatePlanetDialog extends StatefulWidget {
  final VoidCallback onSucc;
  const CreatePlanetDialog(this.onSucc, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CreatePlanetState();
}

class _CreatePlanetState extends State<CreatePlanetDialog> {
  Map<String, String> list = {'Plain': 'plain', '8-bit': 'gamedb'};
  String name = '';
  String about = '';
  String template = 'plain';
  bool creating = false;
  String error = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Planet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            onChanged: (v) {
              setState(() {
                name = v;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Name',
            ),
          ),
          // const Padding(padding: EdgeInsets.only(top: 5)),
          TextField(
            decoration: const InputDecoration(
              hintText: 'About',
            ),
            onChanged: (v) {
              setState(() {
                about = v;
              });
            },
          ),
          Row(
            children: [
              const Text('Template:'),
              const Padding(padding: EdgeInsets.only(right: 10)),
              Expanded(
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: list.entries.map<DropdownMenuItem<String>>((e) {
                    return DropdownMenuItem<String>(
                      value: e.value,
                      child: Text(e.key),
                    );
                  }).toList(),
                  value: template,
                  onChanged: (v) {
                    setState(() {
                      template = v ?? '';
                    });
                  },
                ),
              )
            ],
          ),
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
          onPressed: name.isEmpty || creating
              ? null
              : () async {
                  setState(
                    () {
                      creating = true;
                    },
                  );
                  var rsp = await api('/planet/create', {
                    "name": name,
                    "about": about,
                    "template": template,
                  });
                  if ((rsp['error'] as String).isEmpty) {
                    widget.onSucc();
                  } else {
                    setState(() {
                      error = rsp['error'];
                      creating = false;
                    });
                  }
                },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
