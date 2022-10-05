import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/actions/actions.dart';
import 'package:scbrf/models/models.dart';
import 'package:scbrf/utils/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

var log = getLogger('weview');

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({Key? key}) : super(key: key);
  @override
  WebviewScreenState createState() => WebviewScreenState();
}

class WebviewScreenState extends State<WebviewScreen> {
  WebViewController? controller;

  @override
  Widget build(BuildContext context) {
    injectEthereum(url) {
      String address = StoreProvider.of<AppState>(context).state.address;
      log.d('inject script, address is $address');
      controller!.runJavascript("""(()=>{
  let resolves={}
  window.ethereum = {
      isScarborough: true,
      isMobile: true,
      on(msg, cb) {
        if (msg === 'accountsChanged') {
          cb(['$address'])
        }
      },
      async request(req) {
        console.log('ethereum request called', JSON.stringify(req));
        if (req.method === 'eth_requestAccounts') {
          return ['$address'];
        }
        const requestid = new Date().getTime() + Math.random()
        return await new Promise(resolve=>{
          resolves[requestid] = resolve;
          req.requestid = requestid
          ipc.postMessage(JSON.stringify({...req, requestid}))
        })
      }
  }
  window.ipcResolve = ({requestid, data}) => {
    resolves[requestid](data)
  }
})()""");
    }

    webReply(String obj) {
      controller!.runJavascript('ipcResolve($obj)');
    }

    runWebInvoke(param) async {
      String host = StoreProvider.of<AppState>(context).state.currentStation;
      var client = http.Client();
      try {
        var response = await client.post(Uri.http(host, '/ipc'),
            headers: {"Content-type": "application/json"}, body: param);
        String body = utf8.decode(response.bodyBytes);
        log.d("request api $param get response $body");
        webReply(body);
      } finally {
        client.close();
      }
    }

    return StoreConnector<AppState, Article>(
        distinct: true,
        converter: (Store<AppState> store) => store.state.focus,
        builder: (ctx, article) {
          log.d('rebuild webview and load from ${article.url}');
          return Scaffold(
            appBar: AppBar(
              title: Text(article.title),
            ),
            body: WebView(
              initialUrl: article.url,
              onWebViewCreated: (c) {
                controller = c;
              },
              javascriptChannels: <JavascriptChannel>{
                JavascriptChannel(
                  name: 'ipc',
                  onMessageReceived: (JavascriptMessage message) async {
                    log.d('receive from web ${message.message}');
                    runWebInvoke(message.message);
                  },
                )
              },
              userAgent: 'Planet/MobileJS',
              debuggingEnabled: true,
              onPageStarted: injectEthereum,
              javascriptMode: JavascriptMode.unrestricted,
            ),
          );
        });
  }
}
