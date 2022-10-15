import 'package:flutter/material.dart';
import 'package:scbrf/utils/api.dart';
import 'package:scbrf/models/models.dart';

class CreatePlanetDialog extends StatefulWidget {
  final VoidCallback onSucc;
  final Planet? planet;
  const CreatePlanetDialog(this.onSucc, {Key? key, this.planet})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _CreatePlanetState();
}

class _CreatePlanetState extends State<CreatePlanetDialog> {
  Map<String, String> list = {'Plain': 'plain', '8-bit': 'gamedb'};
  String template = 'plain';
  bool creating = false;
  String error = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.planet != null) {
      nameController.text = widget.planet!.name;
      aboutController.text = widget.planet!.about;
      template = widget.planet!.template;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.planet == null ? "Create" : "Edit"} New Planet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Name',
            ),
            onChanged: (v) {
              setState(() {});
            },
          ),
          // const Padding(padding: EdgeInsets.only(top: 5)),
          TextField(
            controller: aboutController,
            decoration: const InputDecoration(
              hintText: 'About',
            ),
            onChanged: (v) {
              setState(() {});
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
          onPressed: nameController.text.isEmpty || creating
              ? null
              : () async {
                  setState(
                    () {
                      creating = true;
                    },
                  );
                  var rsp = await api('/planet/create', {
                    "id": widget.planet == null ? '' : widget.planet!.id,
                    "name": nameController.text,
                    "about": aboutController.text,
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
