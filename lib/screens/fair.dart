import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scbrf/models/fair_info.dart';
import 'package:scbrf/utils/api.dart';

import '../models/models.dart';

class FairRequestScreen extends StatefulWidget {
  const FairRequestScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FairRequestState();
}

class _FairRequestState extends State<FairRequestScreen> {
  bool isLoading = true;
  FairInfo info = FairInfo.empty();
  String error = '';
  TextEditingController fundController = TextEditingController(text: '0.01');
  TextEditingController durationController = TextEditingController(text: '24');
  TextEditingController passwdController = TextEditingController();
  String? errorPasswd;
  String? errorFund;
  String? errorDuration;
  bool validate() {
    if (passwdController.text.isEmpty) {
      errorPasswd = '不能为空';
    } else {
      errorPasswd = null;
    }
    if (durationController.text.isEmpty) {
      errorDuration = '不能为空';
    } else {
      errorDuration = null;
    }
    if (fundController.text.isEmpty) {
      errorFund = '不能为空';
    } else {
      errorFund = null;
    }
    if (int.parse(durationController.text) * 3600 >= info.durationLimit) {
      errorDuration = '投放时长超过限制';
    } else {
      errorDuration = null;
    }
    setState(() {});
    return errorPasswd == null && errorDuration == null && errorFund == null;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Article>(
        onInit: (store) async {
          var rsp = await api('/fair/prepare', {
            "planetid": store.state.focus.planetid,
            "articleid": store.state.focus.id
          });
          setState(() {
            info = FairInfo.fromJson(rsp);
            isLoading = false;
          });
        },
        builder: (ctx, focus) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Fair Request'),
              centerTitle: false,
              actions: [
                Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        FlutterClipboard.copy(info.address).then((_) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('wallet address has been copied!'),
                          ));
                        });
                      },
                      child: const Icon(
                        Icons.copy_all_outlined,
                        size: 26.0,
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GestureDetector(
                      onTap: () async {
                        var navigator = Navigator.of(context);
                        if (validate()) {
                          log.d('validate succ, action ...');
                          setState(() {
                            isLoading = true;
                          });
                          var rsp = await api('/fair/request', {
                            "articleid": focus.id,
                            "planetid": focus.planetid,
                            "value": fundController.text,
                            "duration": durationController.text,
                            "passwd": passwdController.text
                          });
                          setState(() {
                            isLoading = false;
                            error = rsp["error"];
                            if (error.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Succ!'),
                              ));
                              navigator.pop();
                            }
                          });
                        }
                      },
                      child: const Icon(
                        Icons.airport_shuttle_outlined,
                        size: 26.0,
                      ),
                    )),
              ],
            ),
            body: isLoading
                ? Center(
                    heightFactor: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const Padding(padding: EdgeInsets.only(top: 30)),
                          Text(
                            '正在请求区块链，可能需要一点时间，取决于你的网络状况',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .caption!
                                .copyWith(height: 2),
                          )
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '文章 ${focus.title} 将会被投放到集市，所有人都有机会看到您的文章，也可以看到您的整个站点',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(height: 1.5),
                          ),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          Text(
                              '您需要为此支付 Gas 费(预计: ${info.gas})和社区捐赠(金额由您决定但不能为空，将全数用于支援社区运作)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(height: 1.5)),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          Text(
                              '您的钱包地址是：${info.address},当前的余额是: ${info.balance} ETH (测试网络:Goerli).',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(height: 1.5)),
                          TextField(
                            controller: fundController,
                            decoration: InputDecoration(
                              prefix: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text('捐赠金额:',
                                    style: Theme.of(context).textTheme.caption),
                              ),
                              errorText: errorFund,
                              suffix: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text('ETH',
                                    style: Theme.of(context).textTheme.caption),
                              ),
                            ),
                          ),
                          TextField(
                            controller: durationController,
                            decoration: InputDecoration(
                              prefix: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text('投放时长:',
                                    style: Theme.of(context).textTheme.caption),
                              ),
                              errorText: errorDuration,
                              suffix: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text('小时',
                                    style: Theme.of(context).textTheme.caption),
                              ),
                            ),
                          ),
                          TextField(
                            obscureText: true,
                            controller: passwdController,
                            decoration: InputDecoration(
                              errorText: errorPasswd,
                              prefix: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Text('钱包密码:',
                                    style: Theme.of(context).textTheme.caption),
                              ),
                            ),
                          ),
                          Text(
                            error,
                            style: Theme.of(context)
                                .textTheme
                                .button!
                                .copyWith(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        },
        converter: (store) => store.state.focus);
  }
}
