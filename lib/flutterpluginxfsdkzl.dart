import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';


class Flutterpluginxfsdkzl {

  static final Flutterpluginxfsdkzl instance = Flutterpluginxfsdkzl._();
  Flutterpluginxfsdkzl._();

  static const MethodChannel _channel =
      const MethodChannel('flutterpluginxfsdkzl');

  // the following three methods would be called to change for both SpeechRecognizer & SpeechSynthesizer
  static const String _METHOD_INITWITHAPPID = 'initWithAppId';
  static const String _METHOD_SETPARAMETER = 'setParameter';
  static const String _METHOD_DISPOSE = 'dispose';

  /// for SpeechRecogniaer only 语音识别
  static const String _METHOD_STARTLISTENING = 'startListening';
  static const String _METHOD_STOPLISTENING = 'stopListening';
  static const String _METHOD_CANCELLISTENING = 'cancelListening';


//  /// for SpeechSynthesizer only 语音合成
  static const String _METHOD_START_SPEAKING = 'startSpeaking';
  static const String _METHOD_PAUSE_SPEAKING = 'pauseSpeaking';
  static const String _METHOD_RESUME_SPEAKING = 'resumeSpeaking';
  static  String _METHOD_STOP_SPEAKING = 'stopSpeaking';
  static const String _METHOD_IS_SPEAKING = 'isSpeaking';

  /// 语音评测 开始
  static const String  _METHOD_START_SpeechEvaluator = "iFlySpeechEvaluator";
  /// 语音评测 结束
  static const String  _METHOD_START_SpeechEvaluatorStop = "iFlySpeechEvaluatorStop";

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  //初始化
  Future<void> initWithAppId({@required String iosAppID, @required String androidAppID}) async {
    assert(iosAppID != null && iosAppID.isNotEmpty);
    assert(androidAppID != null && androidAppID.isNotEmpty);
    return _channel.invokeMethod(
      _METHOD_INITWITHAPPID, Platform.isIOS ? iosAppID : androidAppID,
    );
  }

  Future<void> setParameter(Map<String, dynamic> param) async {
    _channel.invokeMethod(_METHOD_SETPARAMETER, param);
  }

  Future<void> dispose() async {
    _channel.invokeMethod(_METHOD_DISPOSE);
  }

  //开始评测
  Future<void> startPingceListening({XfZLListener listener,String textT}) async {
    _channel.setMethodCallHandler((MethodCall call) async {

      if (call.method == 'onBeginOfSpeech' && listener?.onBeginOfSpeech != null) {
        listener.onBeginOfSpeech();
      }
      if (call.method == 'onCancel' && listener?.onCancel != null) {
        listener.onCancel();
      }
      if (call.method == 'onEndOfSpeech' && listener?.onEndOfSpeech != null) {
        listener.onEndOfSpeech();
      }
      if (call.method == 'onCompleted' && listener?.onCompleted != null) {
        listener.onCompleted(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onResults' && listener?.onResults != null) {
        listener.onResults(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onVolumeChanged' && listener?.onVolumeChanged != null) {
        listener.onVolumeChanged(call.arguments);
      }

    });
    _channel.invokeMethod(_METHOD_START_SpeechEvaluator,{"text":textT});
  }

  //结束测评
  Future<void> stopPingceListening() async {
    _channel.invokeMethod(_METHOD_START_SpeechEvaluatorStop);
  }

  Future<void> stopListening() async {
    _channel.invokeMethod(_METHOD_STOPLISTENING);
  }

  Future<void> cancelListenning() async {
    _channel.invokeMethod(_METHOD_CANCELLISTENING);
  }




  Future<void> startListening({XfZLListener listener}) async {
    _channel.setMethodCallHandler((MethodCall call) async {

      if (call.method == 'onBeginOfSpeech' && listener?.onBeginOfSpeech != null) {
        listener.onBeginOfSpeech();
      }
      if (call.method == 'onCancel' && listener?.onCancel != null) {
        listener.onCancel();
      }
      if (call.method == 'onEndOfSpeech' && listener?.onEndOfSpeech != null) {
        listener.onEndOfSpeech();
      }
      if (call.method == 'onCompleted' && listener?.onCompleted != null) {
        listener.onCompleted(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onResults' && listener?.onResults != null) {
        listener.onResults(call.arguments[0], call.arguments[1]);
      }
      if (call.method == 'onVolumeChanged' && listener?.onVolumeChanged != null) {
        listener.onVolumeChanged(call.arguments);
      }

    });
    _channel.invokeMethod(_METHOD_STARTLISTENING);
  }


  //语音合成
  Future<void> startSpeaking({@required String string, XfZLListener listener}) async{

    _channel.setMethodCallHandler((MethodCall call) async{
      if (call.method == 'onSpeakBegin' && listener?.onSpeakBegin != null) {
        listener.onSpeakBegin();
      }
      if (call.method == 'onBufferProgress' && listener?.onBufferProgress != null) {
        listener.onBufferProgress(call.arguments[0],call.arguments[1],call.arguments[2],call.arguments[3]);
      }
      if (call.method == 'onSpeakProgress' && listener?.onSpeakProgress != null) {
        listener.onSpeakProgress(call.arguments[0],call.arguments[1],call.arguments[2]);
      }
      if (call.method == 'onVolumeChanged' && listener?.onVolumeChanged != null) {
        listener.onVolumeChanged(call.arguments);
      }
      if (call.method == 'onSpeakPaused' && listener?.onSpeakPaused != null) {
        listener.onSpeakPaused();
      }
      if (call.method == 'onCompleted' && listener?.onCompleted != null) {
        listener.onCompleted(call.arguments[0],call.arguments[1]);
      }
      if (call.method == 'onSpeakResumed' && listener?.onSpeakResumed != null) {
        listener.onSpeakResumed();
      }
    });
    _channel.invokeMethod(_METHOD_START_SPEAKING, string);
  }

  Future<void> pauseSpeaking() async {
    _channel.invokeMethod(_METHOD_PAUSE_SPEAKING);
  }

  Future<void> resumeSpeaking() async {
    _channel.invokeMethod(_METHOD_RESUME_SPEAKING);
  }

  Future<void> stopSpeaking() async {
    _channel.invokeMethod(_METHOD_STOP_SPEAKING);
  }

  Future<bool> isSpeaking() async {
    return _channel.invokeMethod(_METHOD_IS_SPEAKING);
  }

  void clearListener() {
    _channel.setMethodCallHandler(null);
  }


}

//回调方法的类
class XfZLListener{
  VoidCallback onBeginOfSpeech;
  VoidCallback onEndOfSpeech;
  VoidCallback onCancel;

  void Function(Map<dynamic, dynamic> error, String filePath) onCompleted;
  void Function(String result, bool isLast) onResults;
  void Function(int volume) onVolumeChanged;

  VoidCallback onSpeakResumed;
  VoidCallback onSpeakPaused;
  VoidCallback onSpeakBegin;
  void Function(int p, int b, int e, String a) onBufferProgress;
  void Function(int p, int b, int e) onSpeakProgress;

  XfZLListener({
    this.onBeginOfSpeech,
    this.onResults,
    this.onVolumeChanged,
    this.onEndOfSpeech,
    this.onCompleted,
    this.onCancel,

    this.onSpeakResumed,
    this.onSpeakBegin,
    this.onSpeakPaused,
    this.onBufferProgress,
    this.onSpeakProgress
  });
}

class XFZLVoiceParam {
  String speech_timeout;
  String domain;
  String result_type;
  String timeout;
  String power_cycle;
  String sample_rate;
  String engine_type;
  String local;
  String cloud;
  String mix;
  String auto;
  String text_encoding;
  String result_encoding;
  String player_init;
  String player_deactive;
  String recorder_init;
  String recorder_deactive;
  String speed;
  String pitch;
  String tts_audio_path;
  String vad_enable;
  String vad_bos;
  String vad_eos;
  String voice_name;
  String voice_id;
  String voice_lang;
  String volume;
  String tts_buffer_time;
  String tts_data_notify;
  String next_text;
  String mpplayinginfocenter;
  String audio_source;
  String asr_audio_path;
  String asr_sch;
  String asr_ptt;
  String local_grammar;
  String cloud_grammar;
  String grammar_type;
  String grammar_content;
  String lexicon_content;
  String lexicon_name;
  String grammar_list;
  String nlp_version;

  String sub;
  String plev;
  String ise_unite;
  String rst;
  String extra_ability;
  String category;
  String language;
  String result_level;
  String ise_audio_path;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> param = {
      'speech_timeout': speech_timeout,
      'domain': domain,
      'result_type': result_type,
      'timeout': timeout,
      'power_cycle': power_cycle,
      'sample_rate': sample_rate,
      'engine_type': engine_type,
      'local': local,
      'cloud': cloud,
      'mix': mix,
      'auto': auto,
      'text_encoding': text_encoding,
      'result_encoding': result_encoding,
      'player_init': player_init,
      'player_deactive': player_deactive,
      'recorder_init': recorder_init,
      'recorder_deactive': recorder_deactive,
      'speed': speed,
      'pitch': pitch,
      'tts_audio_path': tts_audio_path,
      'vad_enable': vad_enable,
      'vad_bos': vad_bos,
      'vad_eos': vad_eos,
      'voice_name': voice_name,
      'voice_id': voice_id,
      'voice_lang': voice_lang,
      'volume': volume,
      'tts_buffer_time': tts_buffer_time,
      'tts_data_notify': tts_data_notify,
      'next_text': next_text,
      'mpplayinginfocenter': mpplayinginfocenter,
      'audio_source': audio_source,
      'asr_audio_path': asr_audio_path,
      'asr_sch': asr_sch,
      'asr_ptt': asr_ptt,
      'local_grammar': local_grammar,
      'cloud_grammar': cloud_grammar,
      'grammar_type': grammar_type,
      'grammar_content': grammar_content,
      'lexicon_content': lexicon_content,
      'lexicon_name': lexicon_name,
      'grammar_list': grammar_list,
      'nlp_version': nlp_version,
      "sub":sub,
      "plev":plev,
      "ise_unite":ise_unite,
      "rst":rst,
      "extra_ability":extra_ability,
      "category":category,
      "language":language,
      "result_level":result_level,
      "ise_audio_path":ise_audio_path,

    };
    final isNull = (key, value) {
      return value == null;
    };
    param.removeWhere(isNull);
    return param;
  }
}

