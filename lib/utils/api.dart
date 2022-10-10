import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:scbrf/utils/logger.dart';

var log = getLogger('api');
String apiEntry = '';

Future<Map<String, dynamic>> api(String url, Map<String, dynamic>? body) async {
  var client = http.Client();
  try {
    log.d('api to $url with body $body');
    var response = await client.post(Uri.http(apiEntry, url), body: body);
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
