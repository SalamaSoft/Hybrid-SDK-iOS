//
//  WebController.h
//  Workmate
//
//  Created by XingGu Liu on 12-2-2.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NativeService.h"

#import "ResourceFileManager.h"

typedef enum LocalWebLocationType {LocalWebLocationTypeDocuments, LocalWebLocationTypeLibraryCache} LocalWebLocationType;

@interface WebController : NSObject
{
    @private
    LocalWebLocationType _localWebLocationType;

    NSString *_webPackageName;
    NSString *_webRootDirPath;
    
    //NSString *_documentPath;
    NSString* _webBaseDirPath;
    
    NSString *_tempPath;

    NSString *_currentDirPath;
    
    //UIWebView *_webView;
    //NativeService *_nativeService;
    NSURL* _webBaseURL;
    
    ResourceFileManager* _resourceFileManager;
    
    NSMutableDictionary* _sessionContainer;
    
    dispatch_queue_t _queueForWeb;
}

//@property (nonatomic, retain) UIWebView *webView;

/**
 * nativeService
 */
@property (nonatomic, retain) NativeService *nativeService;

/**
 * ResourceFileManager
 */
@property (nonatomic, retain) ResourceFileManager* resourceFileManager;

/**
 * 设置debug模式
 * @param isDebug debug模式
 */
+(void)setDebugMode:(bool)isDebug;

/**
 * 编码JavaScript参数值
 * @param input 输入值
 * @return 编码后的值
 */
+(char*)encodeToScriptStringValue:(const char*)input;

/**
 * 设置路径为忽略iCloud自动同步
 * @param filePath 路径
 * @return 是否成功设置
 */
+(BOOL)setSkipBackupAttributeToFilePath:(NSString*)filePath;

/**
 * 初始化
 * @param webPackageName 本地页面压缩包名
 * @param localWebLocationType 存储位置类型
 * @return WebController
 */
- (id)init:(NSString*)webPackageName localWebLocationType:(LocalWebLocationType)localWebLocationType;

/**
 * 初始化(本地网页目录已存在，无需解压zip)
 * @param existingWebRootPath 本地网页根路径
 * @return WebController
 */
- (id)initWithExistingWebRootPath:(NSString*)existingWebRootPath;

/**
 * 改变本地网页根路径
 */
- (void)switchToWebRootDirPath:(NSString*)webRootDirPath;

/**
 * 本地页面根目录路径
 */
-(NSString*) webRootDirPath;

//-(NSString*) documentPath;

/**
 * 本地页面存储目录路径(webRootDirPath的上层目录)
 */
- (NSString*)baseStorageDirPath;

/**
 * 临时目录路径
 */
-(NSString*) tempPath;

//-(void) setWebView:(UIWebView*)webView;

/**
 * 取得实际路径
 * @param virtualPath 相对路径
 * @return 实际路径
 */
-(NSString*) toRealPath: (NSString*) virtualPath;

/**
 * 装载本地页面
 * @param relativeUrl 本地页面URL
 * @param webView LocalWebView
 */
-(void) loadLocalPage:(NSString*)relativeUrl webView:(UIWebView*)webView;

/**
 * 装载URL
 * @param url URL
 * @param webView UIWebView
 */
-(void) loadRequest:(NSString*)url webView:(UIWebView*)webView;

-(BOOL) handleUrlLoadingEvent:(NSString*)url webView:(UIWebView *)webView thisView:(id)thisView;

/**
 * 调用本地Service
 * @param invokeMsg 指令
 * @param webView UIWebView实例
 * @param thisView 当前View实例
 */
-(void) invokeNativeService:(InvokeMsg*)invokeMsg webView:(UIWebView *)webView thisView:(id)thisView;

/**
 * 设置session值
 * @param name 名称
 * @param value 值
 */
-(void)setSessionValueWithName:(NSString*)name value:(NSString*)value;

/**
 * 删除session值
 * @param name 名称
 */
-(void)removeSessionValueWithName:(NSString*)name;

/**
 * 取得session值
 * @param name 名称
 * @return session值
 */
-(NSString*)getSessionValueWithName:(NSString*)name;

@end
