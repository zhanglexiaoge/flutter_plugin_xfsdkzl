import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutterpluginxfsdkzl/flutterpluginxfsdkzl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String iflyResultString = '点击开始测评，点击结束测评';
  final voice = Flutterpluginxfsdkzl.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    voice.initWithAppId(iosAppID: '57a95290', androidAppID: 'bef67231');
    final param = new XFZLVoiceParam();
    param.sub = 'ise';
    param.plev = '0';
    param.ise_unite = '1';
    param.rst = 'entirety';
    param.extra_ability = 'syll_phone_err_msg;pitch;multi_dimension';
    param.vad_bos = '5000';
    param.vad_eos = '1800';
    param.category = 'read_sentence';
    param.language = 'zh_cn';
    param.result_level = 'complete';
    param.speech_timeout = '-1';
    param.audio_source = '1';
    param.sample_rate = '16000';
    param.text_encoding = 'utf-8';
    param.result_type = 'plain';
    param.ise_audio_path = 'eva.pcm';

    voice.setParameter(param.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body:Column(
          children: [
            RaisedButton(
              onPressed: () {
                onstartAction();
              },
              child: Text('开始测评'),
            ),
            RaisedButton(
              onPressed: (){
                Flutterpluginxfsdkzl.instance.stopPingceListening();
              },
              child: Text('停止测评'),
            ),
            Container(
              height: 20,
            ),
            Center(child: Text(this.iflyResultString)),
          ],
        ),
      ),
    );
  }

  onstartAction() {
    final listen = XfZLListener(
        onVolumeChanged: (volume) {
          print('$volume');
        },
        onResults: (String result, isLast) {

          print(result);

          if (result.length > 0) {
            setState(() {
              this.iflyResultString =  "测评结果：" + '666666';
            });
          }
        },
        onCompleted: (Map<dynamic, dynamic> errInfo, String filePath) {

          print('777777777777');
          print(errInfo.toString());
          setState(() {

          });
        }
    );
    //textT 参数为你需要测评的内容
    Flutterpluginxfsdkzl.instance.startPingceListening(listener: listen,textT: "功能测试1234567890");
  }
}
