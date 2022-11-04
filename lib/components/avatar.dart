import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Avatar extends StatefulWidget {
  final String url;
  final String title;
  final double? size;
  const Avatar(this.url, this.title, {Key? key, this.size}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  bool imgError = false;
  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty || kDebugMode) {
      return CircleAvatar(
        radius: widget.size,
        child: Text(
          widget.title.substring(0, 1).toUpperCase(),
          style: TextStyle(fontSize: widget.size ?? 8),
        ),
      );
    } else {
      return CircleAvatar(
        radius: widget.size,
        backgroundImage:
            CachedNetworkImageProvider(widget.url, errorListener: () {
          setState(() {
            imgError = true;
          });
        }),
        child: Text(imgError ? widget.title.substring(0, 1).toUpperCase() : '',
            style: TextStyle(fontSize: widget.size ?? 8)),
      );
    }
  }
}
