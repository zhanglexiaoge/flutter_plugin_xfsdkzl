#import "FlutterpluginxfsdkzlPlugin.h"
#import <iflyMSC/iflyMSC.h>
#import <objc/runtime.h>

static FlutterMethodChannel *_channel = nil;

@interface FlutterpluginxfsdkzlPlugin () <IFlySpeechEvaluatorDelegate>
@property (nonatomic, strong) NSString *resultString;
@end

@implementation FlutterpluginxfsdkzlPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutterpluginxfsdkzl"
            binaryMessenger:[registrar messenger]];
  FlutterpluginxfsdkzlPlugin* instance = [[FlutterpluginxfsdkzlPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  _channel = channel;
}

static NSString * const _METHOD_INITWITHAPPID = @"initWithAppId";
static NSString * const _METHOD_SETPARAMETER = @"setParameter";
static NSString * const _METHOD_DISPOSE = @"dispose";

/// for  IFlySpeechEvaluator
/// 语音评测 开始
static NSString * const _METHOD_START_SpeechEvaluator = @"iFlySpeechEvaluator";
/// 语音评测 结束
static NSString * const _METHOD_START_SpeechEvaluatorStop = @"iFlySpeechEvaluatorStop";

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([_METHOD_INITWITHAPPID isEqualToString:call.method]) {
      //初始化 讯飞
      [self iflyInit:call.arguments];

  } else if ([_METHOD_SETPARAMETER isEqualToString:call.method]) {
      //设置讯飞参数
      [self setParameter:call.arguments];
  }else if ([_METHOD_START_SpeechEvaluator isEqualToString:call.method]){
      //开始语音测评
      NSLog(@"%@",call.arguments);
      [self onBtnStartSpeechEvaluator:call.arguments];
  }else if ([_METHOD_START_SpeechEvaluatorStop isEqualToString:call.method]){
      //结束语音测评
      [self onBtnStopSpeechEvaluator];
  }else {
    result(FlutterMethodNotImplemented);
  }
}

//初始化
- (void)iflyInit:(NSString *)appId {
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", appId];
    [IFlySpeechUtility createUtility:initString];
    //语音评测
    [[IFlySpeechEvaluator sharedInstance] setDelegate:self];
    
    //语音识别类
    //[[IFlySpeechRecognizer sharedInstance] setDelegate:self];
    // 语音合成
   // [[IFlySpeechSynthesizer sharedInstance] setDelegate:self];

}

//设置讯飞参数
- (void)setParameter:(NSDictionary *)param {
    
    
    [param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        //语音评测
        [[IFlySpeechEvaluator sharedInstance]  setParameter:obj forKey:key];
        
//        [[IFlySpeechRecognizer sharedInstance] setParameter:obj forKey:key];
//        [[IFlySpeechSynthesizer sharedInstance] setParameter:obj forKey:key];
    }];
}
- (void)onBtnStartSpeechEvaluator:(NSDictionary *)param {
    

    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

    NSLog(@"text encoding:%@",[[IFlySpeechEvaluator sharedInstance] parameterForKey:[IFlySpeechConstant TEXT_ENCODING]]);
    NSLog(@"language:%@",[[IFlySpeechEvaluator sharedInstance] parameterForKey:[IFlySpeechConstant LANGUAGE]]);

    BOOL isUTF8=[[[IFlySpeechEvaluator sharedInstance] parameterForKey:[IFlySpeechConstant TEXT_ENCODING]] isEqualToString:@"utf-8"];
    BOOL isZhCN=[[[IFlySpeechEvaluator sharedInstance] parameterForKey:[IFlySpeechConstant LANGUAGE]] isEqualToString:@"zh_cn"];
    NSString *textTemp = @"";
    if ([[param allKeys] containsObject:@"text"] ) {
        textTemp = param[@"text"];
    }
    

    NSMutableData *buffer = nil;
    buffer= [NSMutableData dataWithData:[textTemp dataUsingEncoding:encoding]];
    NSLog(@" \nen buffer length: %lu",(unsigned long)[buffer length]);


    BOOL ret = [[IFlySpeechEvaluator sharedInstance] startListening:buffer params:nil];

    if(ret){
        //初始化录音环境
        [IFlyAudioSession initRecordingAudioSession];
    }

}

- (void)onBtnStopSpeechEvaluator {
    [[IFlySpeechEvaluator sharedInstance] stopListening];
}
#pragma mark - IFlySpeechEvaluatorDelegate
/*!
 *  volume callback,range from 0 to 30.
 */
- (void)onVolumeChanged:(int)volume buffer:(NSData *)buffer {
    [_channel invokeMethod:@"onVolumeChanged" arguments:@(volume)];
}

/*!
 *  Beginning Of Speech
 */
- (void)onBeginOfSpeech {
    [_channel invokeMethod:@"onBeginOfSpeech" arguments:NULL];
}

/*!
 *  End Of Speech
 */
- (void)onEndOfSpeech {
    
    [_channel invokeMethod:@"onEndOfSpeech" arguments:NULL];
    
}

/*!
 *  callback of canceling evaluation
 */
- (void)onCancel {
    [_channel invokeMethod:@"onCancel" arguments:NULL];
}

/*!
 *  evaluation session completion, which will be invoked no matter whether it exits error.
 *  error.errorCode =
 *  0     success
 *  other fail
 */
- (void)onCompleted:(IFlySpeechError *)errorCode {
    NSLog(@">>>>>> %@ ",errorCode);
    NSDictionary *dic = NSNull.null;
    if (errorCode.errorCode != 0) {
        dic = @{@"code": @(errorCode.errorCode),
                @"type": @(errorCode.errorType),
                @"desc": errorCode.errorDesc
                };
    }
//
//    NSString *path = [[IFlySpeechRecognizer sharedInstance] parameterForKey:@"asr_audio_path"];
//    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory
//                                                              , NSUserDomainMask
//                                                              , YES);
//    NSString *folder = cachePaths.firstObject;
//    NSString *filePath = [folder stringByAppendingPathComponent:path];
    [_channel invokeMethod:@"onCompleted" arguments:@[dic, @"testpath"]];

}

/*!
 *  result callback of speech evaluation
 *  results：evaluation results
 *  isLast：whether or not this is the last result
 */
- (void)onResults:(NSData *)results isLast:(BOOL)isLast{
    
    if (results) {
        NSString *showText = @"";
        
        const char* chResult=[results bytes];
        
        BOOL isUTF8=[[[IFlySpeechEvaluator sharedInstance] parameterForKey:[IFlySpeechConstant RESULT_ENCODING]]isEqualToString:@"utf-8"];
        NSString* strResults=nil;
        if(isUTF8){
            strResults=[[NSString alloc] initWithBytes:chResult length:[results length] encoding:NSUTF8StringEncoding];
        }else{
            NSLog(@"result encoding: gb2312");
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            strResults=[[NSString alloc] initWithBytes:chResult length:[results length] encoding:encoding];
        }
        if(strResults){
            showText = [showText stringByAppendingString:strResults];
        }
        
        self.resultString = showText;
        
        [_channel invokeMethod:@"onResults" arguments:@[showText, @(isLast)]];
    }
}

//测试设置讯飞参数
+ (void)testParam {
    NSMutableArray *paramArr = [NSMutableArray arrayWithCapacity:100];
    [paramArr addObject:[IFlySpeechConstant SPEECH_TIMEOUT]];
    [paramArr addObject:[IFlySpeechConstant IFLY_DOMAIN]];
    [paramArr addObject:[IFlySpeechConstant NET_TIMEOUT]];
    [paramArr addObject:[IFlySpeechConstant POWER_CYCLE]];
    [paramArr addObject:[IFlySpeechConstant SAMPLE_RATE]];
    [paramArr addObject:[IFlySpeechConstant ENGINE_TYPE]];
    [paramArr addObject:[IFlySpeechConstant TYPE_LOCAL]];
    [paramArr addObject:[IFlySpeechConstant TYPE_CLOUD]];
    [paramArr addObject:[IFlySpeechConstant TYPE_MIX]];
    [paramArr addObject:[IFlySpeechConstant TYPE_AUTO]];
    [paramArr addObject:[IFlySpeechConstant TEXT_ENCODING]];
    [paramArr addObject:[IFlySpeechConstant RESULT_ENCODING]];
    [paramArr addObject:[IFlySpeechConstant PLAYER_INIT]];
    [paramArr addObject:[IFlySpeechConstant PLAYER_DEACTIVE]];
    [paramArr addObject:[IFlySpeechConstant RECORDER_INIT]];
    [paramArr addObject:[IFlySpeechConstant RECORDER_DEACTIVE]];
    [paramArr addObject:[IFlySpeechConstant SPEED]];
    [paramArr addObject:[IFlySpeechConstant PITCH]];
    [paramArr addObject:[IFlySpeechConstant TTS_AUDIO_PATH]];
    [paramArr addObject:[IFlySpeechConstant VAD_ENABLE]];
    [paramArr addObject:[IFlySpeechConstant VAD_BOS]];
    [paramArr addObject:[IFlySpeechConstant VAD_EOS]];
    [paramArr addObject:[IFlySpeechConstant VOICE_NAME]];
    [paramArr addObject:[IFlySpeechConstant VOICE_ID]];
    [paramArr addObject:[IFlySpeechConstant VOICE_LANG]];
    [paramArr addObject:[IFlySpeechConstant VOLUME]];
    [paramArr addObject:[IFlySpeechConstant TTS_BUFFER_TIME]];
    [paramArr addObject:[IFlySpeechConstant TTS_DATA_NOTIFY]];
    [paramArr addObject:[IFlySpeechConstant NEXT_TEXT]];
    [paramArr addObject:[IFlySpeechConstant MPPLAYINGINFOCENTER]];
    [paramArr addObject:[IFlySpeechConstant AUDIO_SOURCE]];
    [paramArr addObject:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [paramArr addObject:[IFlySpeechConstant ASR_SCH]];
    [paramArr addObject:[IFlySpeechConstant ASR_PTT]];
    [paramArr addObject:[IFlySpeechConstant LOCAL_GRAMMAR]];
    [paramArr addObject:[IFlySpeechConstant CLOUD_GRAMMAR]];
    [paramArr addObject:[IFlySpeechConstant GRAMMAR_TYPE]];
    [paramArr addObject:[IFlySpeechConstant GRAMMAR_CONTENT]];
    [paramArr addObject:[IFlySpeechConstant LEXICON_CONTENT]];
    [paramArr addObject:[IFlySpeechConstant LEXICON_NAME]];
    [paramArr addObject:[IFlySpeechConstant GRAMMAR_LIST]];
    [paramArr addObject:[IFlySpeechConstant NLP_VERSION]];

    NSMutableString *defineString = [NSMutableString stringWithString:@"\n"];
    NSMutableString *toJson = [NSMutableString stringWithString:@""];
    [paramArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [defineString appendFormat:@"String %@;\n", obj];
        [toJson appendFormat:@"'%@': %@,\n", obj, obj];
    }];
    NSLog(@"********");
    NSLog(defineString);
    NSLog(toJson);

}

@end
