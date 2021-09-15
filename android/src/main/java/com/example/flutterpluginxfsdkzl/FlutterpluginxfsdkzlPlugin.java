package com.example.flutterpluginxfsdkzl;

import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterpluginxfsdkzlPlugin */

public class FlutterpluginxfsdkzlPlugin implements MethodCallHandler {
//public class FlutterpluginxfsdkzlPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    private static String TAG = FlutterpluginxfsdkzlPlugin.class.getSimpleName();

    PluginRegistry.Registrar registrar;
    FlutterpluginxfsdkzlDelegate delegate;
    private static final String CHANNEL = "flutterpluginxfsdkzl";





    static final String METHOD_CALL_INITWITHAPPID = "initWithAppId";
    static final String METHOD_CALL_SETPARAMETER = "setParameter";

    static final String METHOD_CALL_STARTLISTENING = "startListening";
    //  static final String METHOD_CALL_WRITEAUDIO = "writeAudio";
    static final String METHOD_CALL_STOPLISTENING = "stopListening";
    //  static final String METHOD_CALL_ISLISTENING = "isListening";
    static final String METHOD_CALL_CANCELLISTENING = "cancelListening";


    static final String METHOD_CALL_STARTSPEAKING = "startSpeaking";
    static final String METHOD_CALL_PAUSESPEAKING = "pauseSpeaking";
    static final String METHOD_CALL_RESUMESPEAKING = "resumeSpeaking";
    static final String METHOD_CALL_STOPSPEAKING = "stopSpeaking";
    static final String METHOD_CALL_ISSPEAKING = "isSpeaking";


    static final String METHOD_CALL_DISPOSE = "dispose";


    /// for  语音测评
/// 语音评测 开始
    static final String  _METHOD_START_SpeechEvaluator = "iFlySpeechEvaluator";
/// 语音评测 结束
    static final String  _METHOD_START_SpeechEvaluatorStop = "iFlySpeechEvaluatorStop";

//    @Override
//    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
//        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutterpluginxfsdkzl");
//        channel.setMethodCallHandler(this);
//    }


    FlutterpluginxfsdkzlPlugin(final PluginRegistry.Registrar registrar, final FlutterpluginxfsdkzlDelegate delegate) {
        this.registrar = registrar;
        this.delegate = delegate;
    }

    public static void registerWith(Registrar registrar) {
        if (registrar.activity() == null) {
            return;
        }
        final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL);
        final FlutterpluginxfsdkzlDelegate delegate = new FlutterpluginxfsdkzlDelegate(registrar.activity(),channel);
        registrar.addRequestPermissionsResultListener(delegate);
        final FlutterpluginxfsdkzlPlugin instance = new FlutterpluginxfsdkzlPlugin(registrar, delegate);
        channel.setMethodCallHandler(instance);
    }


//    @Override
//    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
//        channel.setMethodCallHandler(null);
//    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (registrar.activity() == null) {
            result.error("no_activity", "image_cropper plugin requires a foreground activity.", null);
            return;
        }

        Log.e(TAG, call.method);
        switch (call.method) {
            case METHOD_CALL_INITWITHAPPID:
                delegate.initWithAppId(call, result);  // recongnnizer & synthesizer
                break;
            case METHOD_CALL_SETPARAMETER:  // recongnnizer & synthesizer
                delegate.setParameter(call, result);
                break;
            case _METHOD_START_SpeechEvaluator:  // 语音测评开始
                delegate.speechEvaluator(call, result);
                break;
            case _METHOD_START_SpeechEvaluatorStop:  // 语音测评结束
                delegate.speechEvaluatorStop(call, result);
                break;
            case METHOD_CALL_DISPOSE: // recongnnizer & synthesizer
                delegate.dispose(call, result);
                break;



//            case METHOD_CALL_STARTLISTENING:
//                delegate.startListening(call, result);
//                break;
//            case METHOD_CALL_STOPLISTENING:
//                delegate.stopListening(call, result);
//                break;
//            case METHOD_CALL_CANCELLISTENING:
//                delegate.cancelListening(call, result);
//                break;

//            case METHOD_CALL_STARTSPEAKING:
//                delegate.startSpeaking(call, result);
//                break;
//            case METHOD_CALL_PAUSESPEAKING:
//                delegate.pauseSpeaking(call, result);
//                break;
//            case METHOD_CALL_RESUMESPEAKING:
//                delegate.resumeSpeaking(call, result);
//                break;
//            case METHOD_CALL_STOPSPEAKING:
//                delegate.stopSpeaking(call, result);
//                break;

            default:
                throw new IllegalArgumentException("Unknown method " + call.method);
        }
    }





//    @Override
//    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
//        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutterpluginxfsdkzl");
//        channel.setMethodCallHandler(this);
//    }
//
//    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
//    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
//    // plugin registration via this function while apps migrate to use the new Android APIs
//    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
//    //
//    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
//    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
//    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
//    // in the same class.
//    public static void registerWith(Registrar registrar) {
//        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutterpluginxfsdkzl");
//        channel.setMethodCallHandler(new FlutterpluginxfsdkzlPlugin());
//    }
//
//    @Override
//    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//        if (call.method.equals("getPlatformVersion")) {
//            result.success("Android " + android.os.Build.VERSION.RELEASE);
//        } else {
//            result.notImplemented();
//        }
//    }
//
//    @Override
//    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
//        channel.setMethodCallHandler(null);
//    }
}

