import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:scbrf/utils/logger.dart';
import 'package:path/path.dart' as path;

var log = getLogger('api');
String apiEntry = '';

Future<Map<String, dynamic>> api(String url, Map<String, dynamic>? body) async {
  var client = http.Client();
  try {
    log.d('api to $url with body $body');
    var response = await client.post(Uri.http(apiEntry, url),
        body: jsonEncode(body), headers: {"content-type": 'application/json'});
    String rspText = utf8.decode(response.bodyBytes);
    log.d('api got response: $rspText');
    return jsonDecode(rspText) as Map<String, dynamic>;
  } catch (error) {
    log.e('api meer error $error');
    return {"error": 'Network Error!'};
  } finally {
    client.close();
  }
}

Future<void> fetch(String url, String localPath) async {
  var client = http.Client();
  try {
    var response = await client.get(Uri.parse(url));
    await File(localPath).writeAsBytes(response.bodyBytes);
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> upload(String p) async {
  var request = http.MultipartRequest("POST", Uri.http(apiEntry, '/upload'));
  request.files.add(await http.MultipartFile.fromPath(
    'file',
    p,
    filename: path.basename(p),
  ));
  var response = await request.send();
  String rspText = await response.stream.bytesToString();
  log.d('api got response: $rspText');
  return jsonDecode(rspText) as Map<String, dynamic>;
}
