package com.example.flutterpluginxfsdkzl;

import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

import androidx.annotation.VisibleForTesting;
import androidx.core.app.ActivityCompat;

import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.EvaluatorListener;
import com.iflytek.cloud.EvaluatorResult;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.Setting;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechEvaluator;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechSynthesizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.SynthesizerListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class FlutterpluginxfsdkzlDelegate implements PluginRegistry.RequestPermissionsResultListener{

    static String TAG = FlutterpluginxfsdkzlDelegate.class.getSimpleName();

    private final PermissionManager permissionManager;
    private final Activity activity;
    private MethodChannel.Result pendingResult;
    private MethodChannel channel;
    private MethodCall methodCall;

    // 评测结果
    private String mLastResult;

// 语音识别   private SpeechRecognizer recognizer;
// 语音合成   private SpeechSynthesizer synthesizer;

    private SpeechEvaluator mIse;

    private String filePath;
    private StringBuilder resultBuilder = new StringBuilder();

    @VisibleForTesting
    static final int REQUEST_RECORD_AUDIO_PERMISSION = 1000;

    interface PermissionManager {
        boolean isPermissionGranted(String permissionName);
        void askForPermission(String permissionName, int requestCode);
    }

    @VisibleForTesting
    FlutterpluginxfsdkzlDelegate(
            final Activity activity,
            final MethodChannel channel,
            final MethodChannel.Result result,
            final MethodCall methodCall,
            final PermissionManager permissionManager
    ){
        this.activity = activity;
        this.pendingResult = result;
        this.methodCall = methodCall;
        this.permissionManager = permissionManager;
        this.channel = channel;
    }



    public FlutterpluginxfsdkzlDelegate( final Activity activity, final MethodChannel channel){
        this(
                activity,
                channel,
                null,
                null,
                new PermissionManager() {
                    @Override
                    public boolean isPermissionGranted(String permissionName) {
                        return ActivityCompat.checkSelfPermission(activity, permissionName) == PackageManager.PERMISSION_GRANTED;
                    }

                    @Override
                    public void askForPermission(String permissionName, int requestCode) {
                        ActivityCompat.requestPermissions(activity, new String[] {permissionName}, requestCode);
                    }
                });
    }
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        boolean permissionGranted = grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
        switch (requestCode) {
            case REQUEST_RECORD_AUDIO_PERMISSION:
                if (permissionGranted) {
                    //startListeningMethod();
                }
                break;

            default:
                return false;
        }
        return true;
    }

//    private void startListeningMethod() {
//        if (recognizer == null){
//            Log.e(TAG, "SpeechRecognizer hasn't been init");
//            pendingResult.error("","SpeechRecognizer hasn't been init", "SpeechRecognizer is null");
//        }
//        else {
//            int code = recognizer.startListening(mRecognizerListener);
//            if (code != ErrorCode.SUCCESS)  Log.e(TAG, "SpeechRecognizer => startListening error: " + code);
//        }
//        pendingResult.success(null);
//    }

    public void initWithAppId(MethodCall call, MethodChannel.Result result) {
        Log.e(TAG, call.method);
        methodCall = call;
        pendingResult = result;

        if (!permissionManager.isPermissionGranted(Manifest.permission.RECORD_AUDIO)) {
            permissionManager.askForPermission(Manifest.permission.RECORD_AUDIO, REQUEST_RECORD_AUDIO_PERMISSION);
        }

        SpeechUtility.createUtility(activity.getApplicationContext(), SpeechConstant.APPID + "=" + call.arguments);
        Setting.setLocationEnable(false);
        //语音识别 语音合成 用不到
//        recognizer = SpeechRecognizer.createRecognizer(activity.getApplicationContext(), new InitListener() {
//            @Override
//            public void onInit(int code) {
//                if (code != ErrorCode.SUCCESS) {
//                    Log.e(TAG, "Failed to init SpeechRecognizer  Code: " + code);
//                }else  Log.e(TAG, "Init SpeechRecognizer Success" );
//            }
//        });
//
//        synthesizer = SpeechSynthesizer.createSynthesizer(activity.getApplicationContext(), new InitListener() {
//            @Override
//            public void onInit(int i) {
//                if (i != ErrorCode.SUCCESS) {
//                    Log.e(TAG, "Failed to init SpeechSynthesizer Code: " + i);
//                }else  Log.e(TAG, "Init SpeechSynthesizer Success" );
//            }
//        });

        mIse  = SpeechEvaluator.createEvaluator(activity.getApplicationContext(),new InitListener() {
            @Override
            public void onInit(int i) {
                if (i != ErrorCode.SUCCESS) {
                    Log.e(TAG, "Failed to init SpeechEvaluator Code: " + i);
                }else  Log.e(TAG, "Init SpeechEvaluator Success" );
            }
        });

        result.success(null);
    }

    public void setParameter(MethodCall call, MethodChannel.Result result) {
        methodCall = call;
        pendingResult = result;
        Log.e(TAG, "setParameter");
        if (mIse == null) {
            Log.e(TAG, "SpeechEvaluator为null");
        } else {
            try {
                Map<String, String> map = (Map<String, String>) call.arguments;
                for (Map.Entry<String, String> entry : map.entrySet()) {
                    if (entry.getKey().equals(SpeechConstant.ASR_AUDIO_PATH)) {
                        filePath = Environment.getExternalStorageDirectory() + "/msc/" + entry.getValue();
                        mIse.setParameter(SpeechConstant.ASR_AUDIO_PATH, filePath);
                    } else {
                        mIse.setParameter(entry.getKey(), entry.getValue());
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
//        if (recognizer == null) {
//            Log.e(TAG, "recongnizer为null");
//        } else {
//            try {
//                Map<String, String> map = (Map<String, String>) call.arguments;
//                for (Map.Entry<String, String> entry : map.entrySet()) {
//                    if (entry.getKey().equals(SpeechConstant.ASR_AUDIO_PATH)) {
//                        filePath = Environment.getExternalStorageDirectory() + "/msc/" + entry.getValue();
//                        recognizer.setParameter(SpeechConstant.ASR_AUDIO_PATH, filePath);
//                    } else {
//                        recognizer.setParameter(entry.getKey(), entry.getValue());
//                    }
//                }
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//        }
//
//        if (synthesizer == null) {
//            Log.e(TAG, "synthesizer 为 null");
//        } else {
//            try {
//                Map<String, String> map = (Map<String, String>) call.arguments;
//                for (Map.Entry<String, String> entry : map.entrySet()) {
//                    if (entry.getKey().equals(SpeechConstant.ASR_AUDIO_PATH)) {
////                        filePath = Environment.getExternalStorageDirectory() + "/msc/" + entry.getValue();
////                        recognizer.setParameter(SpeechConstant.ASR_AUDIO_PATH, filePath);
//                    } else {
//                        synthesizer.setParameter(entry.getKey(), entry.getValue());
//                    }
//                }
//            } catch (Exception e) {
//                e.printStackTrace();
//            }
//        }

        result.success(null);
    }

    public void dispose(MethodCall call, MethodChannel.Result result) {
        methodCall = call;
        pendingResult = result;
//        if (recognizer == null){
//            Log.e(TAG, "SpeechRecognizer hasn't been init");
//            result.error("","SpeechRecognizer hasn't been init", "SpeechRecognizer is null");
//        } else {
//            if(recognizer.isListening())recognizer.cancel();
//            recognizer.destroy();
//            recognizer = null;
//        }
//
//        if (synthesizer == null){
//            Log.e(TAG, "SpeechSynthesizer hasn't been init");
//            result.error("","SpeechSynthesizer hasn't been init", "SpeechSynthesizer is null");
//        } else {
//            if(synthesizer.isSpeaking())synthesizer.stopSpeaking();
//            synthesizer.destroy();
//            synthesizer = null;
//        }

        if (mIse == null){
            Log.e(TAG, "SpeechEvaluator hasn't been init");
            result.error("","SpeechEvaluator hasn't been init", "SpeechEvaluator is null");
        }else {
            if(mIse.isEvaluating())mIse.stopEvaluating();
            mIse.destroy();
            mIse = null;
        }

        result.success(null);
    }

    // 语音评测 开始
    public void speechEvaluator(MethodCall call, MethodChannel.Result result) {
        methodCall = call;
        pendingResult = result;
        if (!permissionManager.isPermissionGranted(Manifest.permission.RECORD_AUDIO)) {
            permissionManager.askForPermission(Manifest.permission.RECORD_AUDIO, REQUEST_RECORD_AUDIO_PERMISSION);
            return;
        }

        if (mIse == null) {
            Log.e(TAG, "speechEvaluator mIse == null");
            pendingResult.error("", "speechEvaluator mIse == null", "speechEvaluator mIse == null");
        } else {
            showTip("评测开始...");
            mIse.startEvaluating("测试功能", null, mEvaluatorListener);
        }
        pendingResult.success(null);
    }

    // 语音评测 结束
    public void speechEvaluatorStop(MethodCall call, MethodChannel.Result result) {
        methodCall = call;
        pendingResult = result;

        if (mIse == null) {
            Log.e(TAG, "mIse == null");
            pendingResult.error("", "mIse == null", "mIse == null");
        } else if (mIse.isEvaluating()) {
            showTip("评测已停止，等待结果中...");
            mIse.stopEvaluating();
        }

        pendingResult.success(null);
    }

    // 评测监听接口
    private EvaluatorListener mEvaluatorListener = new EvaluatorListener() {

        @Override
        public void onResult(EvaluatorResult result, boolean isLast) {
            Log.d(TAG, "evaluator result :" + isLast);

            if (isLast) {
                StringBuilder builder = new StringBuilder();
                builder.append(result.getResultString());

                mLastResult = builder.toString();

                showTip("评测结束 " + mLastResult);
                channel.invokeMethod("onResults", mLastResult);

//                if (isLast) {
//                    resultBuilder.delete(0,resultBuilder.length());
//
//                    ArrayList<Object> args = new ArrayList<>();
//                    arguments.add(null);
//                    arguments.add(filePath);
//                    channel.invokeMethod("onCompleted", args);
//                }


            }
        }

        @Override
        public void onError(SpeechError error) {
            if (error != null) {
                showTip("error:" + error.getErrorCode() + "," + error.getErrorDescription());
            } else {
                Log.d(TAG, "evaluator over");
            }
        }

        @Override
        public void onBeginOfSpeech() {
            // 此回调表示：sdk内部录音机已经准备好了，用户可以开始语音输入
            Log.d(TAG, "evaluator begin");
        }

        @Override
        public void onEndOfSpeech() {
            // 此回调表示：检测到了语音的尾端点，已经进入识别过程，不再接受语音输入
            Log.d(TAG, "evaluator stoped");
        }

        @Override
        public void onVolumeChanged(int volume, byte[] data) {
            showTip("当前音量：" + volume);
            Log.d(TAG, "返回音频数据：" + data.length);
        }

        @Override
        public void onEvent(int eventType, int arg1, int arg2, Bundle obj) {
            // 以下代码用于获取与云端的会话id，当业务出错时将会话id提供给技术支持人员，可用于查询会话日志，定位出错原因
            //	if (SpeechEvent.EVENT_SESSION_ID == eventType) {
            //		String sid = obj.getString(SpeechEvent.KEY_EVENT_SESSION_ID);
            //		Log.d(TAG, "session id =" + sid);
            //	}
        }

    };

    private void showTip(String str) {
        Log.e("lz", "showTip " + str);
    }



}
