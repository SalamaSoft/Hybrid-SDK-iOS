//
//  WebController.m
//  Workmate
//
//  Created by XingGu Liu on 12-2-2.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "WebController.h"
#import "sys/xattr.h"

#import "ZipArchive.h"
#import "InvokeMsg.h"

#import "XmlContentEncoder.h"
#import "SimpleMetoXML.h"
#import "WebVariableStack.h"

//#define EXTRACT_HTML_ZIP_EVERY_TIME_FOR_DEBUG

#define INIT_TIME_CHECK_FILE_NAME @".init_time_file_CHECK_just_for_check"
#define NOTIFICATION_FOR_JAVASCRIPT_USER_INFO_RESULT_NAME @"result"

//#define HTTP_HEADER_NAME_SALAMA_MOBILE_APP @"salama_mobile_app"
//#define HTTP_HEADER_VALUE_SALAMA_MOBILE_APP @"ios"
//#define USER_AGENT_MOBILE_APP @"salamamobileapp"

typedef enum NativeServiceCmdPositionInBlock {
NativeServiceCmdPositionInBlockFirstCmd, 
NativeServiceCmdPositionInBlockNotFirstAndLastCmd, 
NativeServiceCmdPositionInBlockLastCmd
} NativeServiceCmdPositionInBlock;

/*
@interface WebController (PrivateMethod)

-(void) initObjs;

-(void) releaseObjs;

//-(void) extractWebSource;
//-(void) extractWebSourceDir:(NSString*)webSourceDir;

-(void) extractWebSourceZipInBundle;

-(NSString*) scriptCallBackWhenError:(NSString*)callBackFuncName error:(NSString*)error;

-(NSString*) scriptCallBackWhenSucceed:(NSString*)callBackFuncName returnVal:(id)returnVal;

-(void) invokeNativeServiceSingleCmd:(InvokeMsg*)invokeMsg webView:(UIWebView *)webView thisView:(UIViewController*)thisView cmdPositionInBlock:(NativeServiceCmdPositionInBlock)cmdPositionInBlock;

- (BOOL)isNeedExtractZipByCheckingInitTimeCompareToZipFileTime:(NSString*)htmlZipPath;

+ (NSString*)errorMsgOfException:(NSException*)exception;

@end
*/

@implementation WebController

@synthesize nativeService;
@synthesize resourceFileManager = _resourceFileManager;

static bool debugMode = true;

+(void)setDebugMode:(bool)isDebug
{
    debugMode = isDebug;
}

+(char*)encodeToScriptStringValue:(const char*)input;
{
    const char *cur = input;
    char *buffer = NULL;
    char *output = NULL;
    long indx;
    int buffer_size = 0;
    if (input == NULL) return(NULL);
    
    /*
     * allocate an translation buffer.
     */
    buffer_size = 1000;
    buffer = (char *) malloc(buffer_size * sizeof(char));
    
    if (buffer == NULL) {
        return(NULL);
    }
    output = buffer;
    
    while (*cur != '\0') {
        if (output - buffer > buffer_size - 10) {
            indx = output - buffer;
            
            buffer_size += 500;
            buffer = (char*)realloc(buffer, buffer_size);
            output = &buffer[indx];
        }
        
        /*
         * By default one have to encode at least '<', '>', '"' and '&' !
         */
        if (*cur == '"') {
            *output++ = '\\';
            *output++ = '"';
        } else if (*cur == '\r') {
            *output++ = '\\';
            *output++ = 'r';
        } else if (*cur == '\n') {
            *output++ = '\\';
            *output++ = 'n';
        } else if (*cur == '\'') {
            *output++ = '\\';
            *output++ = '\'';
        } else {
            /*
             * Works because on UTF-8, all extended sequences cannot
             * result in bytes in the ASCII range.
             */
            *output++ = *cur;
        }
        cur++;
    }
    *output++ = 0;
    return(buffer);
}

+ (BOOL)setSkipBackupAttributeToFilePath:(NSString *)filePath
{
    u_int8_t attrValue = 1;
    
    int result = setxattr([filePath UTF8String], "com.apple.MobileBackup", &attrValue, sizeof(attrValue), 0, 0);
    
    return (result == 0);
}


- (id)init: (NSString*) webPackageName localWebLocationType:(LocalWebLocationType)localWebLocationType
{
	if(self=[super init])
	{
        //Super init succeeded
        _webPackageName = [[NSString alloc] initWithString:webPackageName];
        _localWebLocationType = localWebLocationType;
        [self initObjs];
    }
    
    return self;
}

- (id)initWithExistingWebRootPath:(NSString*)existingWebRootPath
{
	if(self=[super init])
	{
        //Super init succeeded
        [self switchToWebRootDirPath:existingWebRootPath];
        [self initServiceObjs];
    }
    
    return self;
}

-(void) dealloc
{
    //release objs
    [self releaseObjs];
    
#ifdef CLANG_OBJC_ARC_DISABLED
	[super dealloc];
#endif
    
    SSLogDebug(@"WebController::dealloc");
}

-(NSString*) webRootDirPath
{
    return [_webRootDirPath copy];
}

//-(NSString*) documentPath
//{
//    return [_documentPath copy];
//}

- (NSString *)baseStorageDirPath
{
    return [_webBaseDirPath copy];
}

-(NSString*) tempPath
{
    return [_tempPath copy];
}

-(NSString*) toRealPath: (NSString*) virtualPath
{
    if(virtualPath == nil)
    {
        return nil;
    }
    
    NSString *strTmp = nil;
    
    unichar chr0 = [virtualPath characterAtIndex:0];
    
    if(chr0 == '/')
    {
        strTmp = [virtualPath substringFromIndex:1];
        return [_webRootDirPath stringByAppendingPathComponent:strTmp];
    }
    else if(chr0 == '.')
    {
        strTmp = [virtualPath substringFromIndex:2];
        
        return [_currentDirPath stringByAppendingPathComponent:strTmp];
    }
    else
    {
        return [_currentDirPath stringByAppendingPathComponent:virtualPath];
    }
    
}

-(void) initObjs
{
    //init dir paths ------------------------------
    [self initWebDirPaths];

    //init other objs
    [self initServiceObjs];
}

- (void)initWebDirPaths
{
    NSArray *specialPaths;
    NSString* webBaseDirPath = nil;
    
    if(_localWebLocationType == LocalWebLocationTypeDocuments)
    {
        specialPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        webBaseDirPath = [specialPaths objectAtIndex:0];
    }
    else if(_localWebLocationType == LocalWebLocationTypeLibraryCache)
    {
        specialPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        webBaseDirPath = [specialPaths objectAtIndex:0];
    }
    specialPaths = nil;
    
    _webBaseDirPath = [webBaseDirPath copy];
    _webRootDirPath = [_webBaseDirPath stringByAppendingPathComponent:_webPackageName];
    [self resetPathsAfterWebRootDirPathChanged];
    
    [self extractWebSourceZipInBundle];
    //[self extractWebSource];
    
    if(_localWebLocationType == LocalWebLocationTypeDocuments)
    {
        [WebController setSkipBackupAttributeToFilePath:_webRootDirPath];
    }
}

- (void)initServiceObjs
{
    NSString* strQueueNameForWeb = [NSString stringWithFormat:@"%lld/queueForWeb/WebController/cn.com.salama.www", (long long )[[NSDate date] timeIntervalSince1970]*1000];
    _queueForWeb = dispatch_queue_create([strQueueNameForWeb UTF8String], NULL);
    
    self.nativeService = [[NativeService alloc] init];
    _sessionContainer = [[NSMutableDictionary alloc] init];
}

- (void)switchToWebRootDirPath:(NSString*)webRootDirPath
{
    if([webRootDirPath hasSuffix:@"/"])
    {
        _webRootDirPath = [webRootDirPath substringToIndex:webRootDirPath.length - 1];
    }
    else
    {
        _webRootDirPath = [webRootDirPath copy];
    }
    
    NSRange searchRange = [_webRootDirPath rangeOfString:@"/" options:NSBackwardsSearch];
    _webPackageName = [_webRootDirPath substringFromIndex:searchRange.location + 1];
    _webBaseDirPath = [_webRootDirPath substringToIndex:searchRange.location];
    
    [self resetPathsAfterWebRootDirPathChanged];
}

- (void)resetPathsAfterWebRootDirPathChanged
{
    _webBaseURL = [NSURL fileURLWithPath:_webRootDirPath];
    
    NSArray* specialPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //_tempPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    _tempPath = [[specialPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tmp", _webPackageName]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:_tempPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _currentDirPath = [[NSString alloc] initWithString:_webRootDirPath];
    
    _resourceFileManager = [[ResourceFileManager alloc] initWithStorageDirPath:[_webRootDirPath stringByAppendingPathComponent:@"res"]];
    
    SSLogInfo(@"_webRootDirPath:%@", _webRootDirPath);
    SSLogInfo(@"_tempPath:%@", _tempPath);
    SSLogInfo(@"_currentDirPath:%@", _currentDirPath);
}

-(void) releaseObjs
{
    //_documentPath = nil;
    _webBaseDirPath = nil;
    _webRootDirPath = nil;
    _tempPath = nil;
    
    nativeService = nil;
    _sessionContainer = nil;
    
    dispatch_release(_queueForWeb);
    _queueForWeb = nil;
}

/*
-(void) setWebView:(UIWebView*)webView
{
    if(_webView != nil)
    {
        _webView.delegate = nil;
        _webView = nil;
    }
    
    _webView = webView;
    _webView.delegate = self;
}
*/
-(void) loadLocalPage:(NSString*) relativeUrl  webView:(UIWebView*)webView
{
    if(relativeUrl == nil)
    {
        return;
    }
    
    NSURL *urlPath = [NSURL fileURLWithPath:[self toRealPath:relativeUrl]];

    NSURLRequest *request = [NSURLRequest requestWithURL:urlPath];
    //NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:urlPath];
    
    //[request addValue:HTTP_HEADER_VALUE_SALAMA_MOBILE_APP forHTTPHeaderField:HTTP_HEADER_NAME_SALAMA_MOBILE_APP];
    //NSString* curUserAgent = [request valueForHTTPHeaderField:@"User-Agent"];
    //NSString* myUserAgent = [NSString stringWithFormat:@"%@ %@", curUserAgent, USER_AGENT_MOBILE_APP];
    //SSLogDebug(@"curUserAgent:%@", curUserAgent);
    //[request setValue:USER_AGENT_MOBILE_APP forHTTPHeaderField:@"User_Agent"];
    
    [webView loadRequest:request];
    //NSLog(@"urlPath:%@", urlPath);
    urlPath = nil;
    request = nil;
    
    /*
    NSString* htmlString = [NSString stringWithContentsOfFile:[self toRealPath:relativeUrl] encoding:(NSUTF8StringEncoding) error:nil];
    [webView loadHTMLString:htmlString baseURL:_webBaseURL];
    */
}

-(void) loadRequest:(NSString*)url  webView:(UIWebView*)webView
{
    NSURL *urlPath = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlPath];
    [webView loadRequest:request];
    
    SSLogDebug(@"urlPath:%@", urlPath);
    
    urlPath = nil;
    request = nil;
}

- (void)setSessionValueWithName:(NSString *)name value:(NSString *)value
{
    [_sessionContainer setObject:value forKey:name];
}

- (void)removeSessionValueWithName:(NSString *)name
{
    [_sessionContainer removeObjectForKey:name];
}

- (NSString *)getSessionValueWithName:(NSString *)name
{
    return [_sessionContainer objectForKey:name];
}

/***** Private Methods *****/
-(BOOL)handleUrlLoadingEvent:(NSString *)url webView:(UIWebView *)webView thisView:(id)thisView
{
    __block id msg = [NativeService parseNativeServiceCmd:url];
    if(msg != nil)
    {
        [self invokeNativeService:msg webView:webView thisView:thisView];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void) invokeNativeService:(id)msg webView:(UIWebView *)webView thisView:(id)thisView
{
    NativeServiceCmdPositionInBlock cmdPosition;
    
    if([msg isKindOfClass:[NSArray class]])
    {
        NSArray* msgList = (NSArray*)msg;
        
        for(int i = 0; i < msgList.count; i++)
        {
            if(i == (((NSArray*)msg).count - 1))
            {
                cmdPosition = NativeServiceCmdPositionInBlockLastCmd;
            }
            else if (i == 0)
            {
                cmdPosition = NativeServiceCmdPositionInBlockFirstCmd;
            }
            else {
                cmdPosition = NativeServiceCmdPositionInBlockNotFirstAndLastCmd;
            }

            if(!((InvokeMsg*)[msgList objectAtIndex:i]).isAsync && (((InvokeMsg*)[msgList objectAtIndex:i]).notification == nil || ((InvokeMsg*)[msgList objectAtIndex:i]).notification.length == 0))
            {
                [self invokeNativeServiceSingleCmd:[msgList objectAtIndex:i] webView:webView thisView:thisView cmdPositionInBlock:cmdPosition];
            }
            else
            {
                dispatch_async(_queueForWeb, ^{
                    [self invokeNativeServiceSingleCmd:[msgList objectAtIndex:i] webView:webView thisView:thisView cmdPositionInBlock:cmdPosition];
                });
            }
        }
    }
    else
    {
        if(!((InvokeMsg*)msg).isAsync && (((InvokeMsg*)msg).notification == nil || ((InvokeMsg*)msg).notification.length == 0))
        {
            [self invokeNativeServiceSingleCmd:msg webView:webView thisView:thisView cmdPositionInBlock:NativeServiceCmdPositionInBlockLastCmd];
        }
        else
        {
            dispatch_async(_queueForWeb, ^{
                [self invokeNativeServiceSingleCmd:msg webView:webView thisView:thisView cmdPositionInBlock:NativeServiceCmdPositionInBlockLastCmd];
            });
        }
    }
}

-(void) invokeNativeServiceSingleCmd:(InvokeMsg*)invokeMsg webView:(UIWebView *)webView thisView:(id)thisView cmdPositionInBlock:(NativeServiceCmdPositionInBlock)cmdPositionInBlock
{
    @try {
        //invoke the service method
        SSLogDebug(@"nativeService:%@ method:%@", invokeMsg.target, invokeMsg.method);
        id returnVal = nil;
        returnVal = [nativeService invoke:invokeMsg.target method:invokeMsg.method 
                                      params:invokeMsg.params thisView:thisView];
        
        //handle the variableStack
        if([thisView conformsToProtocol:@protocol(WebVariableStack)])
        {
            if(invokeMsg.returnValueKeeper != nil && invokeMsg.returnValueKeeper.length > 0)
            {
                WebVariableStackScope scope;
                
                if(invokeMsg.keeperScope == nil || invokeMsg.keeperScope.length == 0)
                {
                    scope = WebVariableStackScopeTemp;
                }
                else
                {
                    if([invokeMsg isEqual:@"page"])
                    {
                        scope = WebVariableStackScopePage;
                    }
                    else if([invokeMsg isEqual:@"temp"])
                    {
                        scope = WebVariableStackScopeTemp;
                    }
                    else {
                        scope = WebVariableStackScopeTemp;
                    }
                }

                if(returnVal == nil)
                {
                    [((id<WebVariableStack>)thisView) removeVariable:invokeMsg.returnValueKeeper scope:scope];
                }
                else
                {
                    [((id<WebVariableStack>)thisView) setVariable:returnVal name:invokeMsg.returnValueKeeper scope:scope];
                }
                
            }

            if (cmdPositionInBlock == NativeServiceCmdPositionInBlockLastCmd)
            {
                //clear temp scope
                [((id<WebVariableStack>)thisView) clearVariablesOfScope:WebVariableStackScopeTemp];
            }
        }

        //handle callback
        if(invokeMsg.notification == nil || invokeMsg.notification.length == 0)
        {
            if(invokeMsg.callBackWhenSucceed != nil && invokeMsg.callBackWhenSucceed.length > 0)
            {
                __block NSString* script = [self scriptCallBackWhenSucceed:invokeMsg.callBackWhenSucceed returnVal:returnVal];
                
                if(script != nil && script.length > 0)
                {
                    SSLogDebug(@"nativeService script:%@", script);
                    
                    //invoke in main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [webView stringByEvaluatingJavaScriptFromString:script];
                    });
                }
            }
        }
        else
        {
            //post notification
            NSString* result = [self returnValueToResultString:returnVal];
            NSDictionary* userInfo = nil;
            if(result != nil)
            {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:result, NOTIFICATION_FOR_JAVASCRIPT_USER_INFO_RESULT_NAME, nil];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:invokeMsg.notification object:self userInfo:userInfo];
        }
        
        returnVal = nil;
    }
    @catch (NSException *exception) {
        @try {
            NSString* errorMsg = [WebController errorMsgOfException:exception];
            //error
            if(invokeMsg.notification == nil || invokeMsg.notification.length == 0)
            {
                if(invokeMsg.callBackWhenError != nil && invokeMsg.callBackWhenError.length > 0)
                {
                    NSString* script = [self scriptCallBackWhenError:invokeMsg.callBackWhenError error:errorMsg];
                    //invoke in main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [webView stringByEvaluatingJavaScriptFromString:script];
                    });
                }
            }
            else
            {
                NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorMsg, NOTIFICATION_FOR_JAVASCRIPT_USER_INFO_RESULT_NAME, nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:invokeMsg.notification object:self userInfo:userInfo];
            }
            
            //output log --------------------------------------
            SSLogError(@"Exception %@", errorMsg);
        }
        @catch (NSException *exception1) {
            //error
            NSString* errorMsg = [WebController errorMsgOfException:exception1];
            //output log --------------------------------------
            SSLogError(@"Exception %@", errorMsg);
        }
    }
    @finally {
        //invokeMsg = nil;
    }
}

+ (NSString *)errorMsgOfException:(NSException *)exception
{
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; // 将调用栈拼成输出日志的字符串
    for (NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    return [NSString stringWithFormat:@"%@:%@\n%@", exception.name, exception.reason, symbols];
}

-(NSString*) scriptCallBackWhenError:(NSString*)callBackFuncName error:(NSString*)error
{
    //NSString* errorMsg = [NSString stringWithFormat:@"%@:%@",exception.name, exception.reason];
    char* cFuncParamStr = [WebController encodeToScriptStringValue:[error UTF8String]];
    
    NSString* callBackFuncScript = [NSString stringWithFormat:@"%@('%@')", callBackFuncName, [ NSString stringWithUTF8String:cFuncParamStr]];
    
    free(cFuncParamStr);
    
    return callBackFuncScript;
}

- (NSString*)returnValueToResultString:(id)returnVal
{
    NSString* returnValStr;
    
    if(returnVal == nil)
    {
        returnValStr = @"";
    }
    else
    {
        if([returnVal isKindOfClass:[NSString class]])
        {
            if(((NSString*)returnVal).length == 0)
            {
                returnValStr = @"";
            }
            else {
                returnValStr = returnVal;
            }
        }
        else
        {
            returnValStr = [SimpleMetoXML objectToString:returnVal];
        }
    }
    
    return returnValStr;
}

-(NSString*) scriptCallBackWhenSucceed:(NSString*)callBackFuncName returnVal:(id)returnVal
{
    if(callBackFuncName != nil && callBackFuncName.length > 0) 
    {
        NSString* returnValStr = [self returnValueToResultString:returnVal];
        
        char* cFuncParamStr = [WebController encodeToScriptStringValue:[returnValStr UTF8String]];
        
        
        NSString* callBackFuncScript = [NSString stringWithFormat:@"%@('%@')", callBackFuncName, [NSString stringWithUTF8String:cFuncParamStr]];
        
        free(cFuncParamStr);
        
        //returnValStr = nil;
        return callBackFuncScript;
    }
    else
    {
        return nil;
    }
}

/*
-(void)extractWebSource
{
    NSArray* applicationDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    NSString* appDir = [applicationDirs objectAtIndex:0];
    SSLogDebug(@"app dir:%@", appDir);
    
    NSString* htmlDirInApplication = [appDir stringByAppendingPathComponent:_webPackageName];
    BOOL isDir;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:htmlDirInApplication isDirectory:&isDir])
    {
        if(isDir)
        {
            [self extractWebSourceDir:htmlDirInApplication];
        }
        else 
        {
            return;
        }
    }
    else 
    {
        [self extractWebSourceZipInBundle];
    }
}

- (void)extractWebSourceDir:(NSString*)webSourceDir
{
    BOOL isDir;

    BOOL isHtmlDirExists = [[NSFileManager defaultManager] fileExistsAtPath:_webRootDirPath isDirectory:&isDir];
    
    if(isHtmlDirExists && !isDir)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_webRootDirPath error:nil];
        isHtmlDirExists = NO;
    }
    
    if(isHtmlDirExists)
    {
        if(debugMode)
        {
            [[NSFileManager defaultManager] removeItemAtPath:_webRootDirPath error:nil];
            [[NSFileManager defaultManager] copyItemAtPath:webSourceDir toPath:_webRootDirPath error:nil];
        }
    }
    else 
    {
        [[NSFileManager defaultManager] copyItemAtPath:webSourceDir toPath:_webRootDirPath error:nil];
    }

}
*/

//These are private method below.
-(void) extractWebSourceZipInBundle
{
    /*
     //get the filename without the extension of ".zip"
     NSString *fileName = nil;
     NSRange rangFileName = [zipFileName rangeOfString:@".zip" options:NSBackwardsSearch];
     
     if(rangFileName.location != NSNotFound)
     {
     fileName = [zipFileName substringToIndex:rangFileName.location]; 
     }
     else
     {
     fileName = [[NSString alloc] initWithString:zipFileName];
     }
     */

    //get the resource path. type is fixed by "zip"
    NSString *htmlZipPath = [[NSBundle mainBundle] pathForResource:_webPackageName ofType:@"zip"];
    
    //check if the zip file exists
    if(htmlZipPath == nil)
    {
        return;
    }
    
    //check if target dir exists
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isNeedUnzip = NO;
    
    //check if target dir exists    
    if([fm fileExistsAtPath:_webRootDirPath isDirectory:&isDir])
    {
        if(!isDir)
        {
            //dir exists but not dir, then delete it
            [fm removeItemAtPath:_webRootDirPath error:nil];
            
            isNeedUnzip = YES;
        }
        else
        {
            //html root dir exists, then check the init_time_check_file
            isNeedUnzip =[self isNeedExtractZipByCheckingInitTimeCompareToZipFileTime:htmlZipPath];
        }
    }
    else
    {
        //path not exists, then create it
        isNeedUnzip = YES;
    }
    
    //DEBUG
    if(debugMode)
    {
        NSLog(@"WebController is in debug mode, then it extracts html.zip every time.");
        isNeedUnzip = YES;
    }
    
    if(isNeedUnzip)
    {
        NSLog(@"WebController unzip files...");
        ZipArchive *zipUtil = [[ZipArchive alloc] init];
        
        if ([zipUtil UnzipOpenFile:htmlZipPath]) {
            [zipUtil UnzipFileTo:_webBaseDirPath overWrite:YES];
            [zipUtil UnzipCloseFile];
        }
        
        zipUtil = nil;
    }
    
    htmlZipPath = nil;
    fm = nil;
}

- (BOOL)isNeedExtractZipByCheckingInitTimeCompareToZipFileTime:(NSString*)htmlZipPath
{
    NSString* initTimeCheckFilePath = [_webRootDirPath stringByAppendingPathComponent:INIT_TIME_CHECK_FILE_NAME];
    if([[NSFileManager defaultManager] fileExistsAtPath:initTimeCheckFilePath])
    {
        NSString* initMSStr = [NSString stringWithContentsOfFile:initTimeCheckFilePath encoding:NSUTF8StringEncoding error:nil];
        NSDate* initTime = [NSDate dateWithTimeIntervalSince1970:[initMSStr doubleValue]];
        
        NSDictionary* fileAttrOfZip = [[NSFileManager defaultManager] attributesOfItemAtPath:htmlZipPath error:nil];
        NSDate* creationDateOfZip = [fileAttrOfZip objectForKey:NSFileCreationDate];

        SSLogDebug(@"last initTime:%@ creationDateOfZip:%@", initTime, creationDateOfZip);

        if([creationDateOfZip compare:initTime] == NSOrderedDescending)
        {
            NSDate* now = [NSDate date];
            NSString* nowMSStr = [NSString stringWithFormat:@"%f", [now timeIntervalSince1970]];
            [nowMSStr writeToFile:initTimeCheckFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        NSDate* now = [NSDate date];
        NSString* nowMSStr = [NSString stringWithFormat:@"%f", [now timeIntervalSince1970]];
        [nowMSStr writeToFile:initTimeCheckFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        return YES;
    }
    
}

//UIWebViewDelegate

@end
