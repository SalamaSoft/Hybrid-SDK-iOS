//
//  SalamaAppService.h
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SalamaDataService.h"
#import "WebManager.h"
#import "SalamaUserService.h"
#import "SalamaWebService.h"
#import "SalamaCloudService.h"
#import "SalamaNativeService.h"

@interface AppAuthInfo : NSObject

@property(nonatomic, retain) NSString* appId;
@property(nonatomic, retain) NSString* appToken;
@property(nonatomic, assign) long long expiringTime;

@end

@interface AppInfo : NSObject

@property (nonatomic, retain) NSString* appServiceHttpUrl;
@property (nonatomic, retain) NSString* appServiceHttpsUrl;

@property (nonatomic, retain) NSString* myAppServiceHttpUrl;
@property (nonatomic, retain) NSString* myAppServiceHttpsUrl;

@end

@interface SalamaAppService : NSObject
{
    @private
    BOOL _dedicatedServerMode;
    
    NSString* _appId;
    NSString* _appSecret;
    NSString* _bundleId;

    AppAuthInfo* _appAuthInfo;
    AppInfo* _appInfo;
    
    SalamaDataService* _dataService;
    NSLock* _lockForNewDataId;
    
    NSString* _easyAppServiceHttpHost;
    NSString* _easyAppServiceHttpsHost;
    NSString* _easyAppServiceHostPrefix;
    int _easyAppServiceHttpPort;
    int _easyAppServiceHttpsPort;
    NSString* _easyAppServiceHttpUrl;
    NSString* _easyAppServiceHttpsUrl;
    NSString* _myAppServiceHttpUrl;
    NSString* _myAppServiceHttpsUrl;
    
    NSString* _udid;
    NSString* _udidRemovedHyphen;
    
    NSString* _systemLanguage;
    NSString* _textFileName;
    
    WebService* _webService;
    BOOL _notUseEasyAppService;
}

@property (nonatomic, readonly) NSString* appId;
@property (nonatomic, readonly) NSString* appServiceHttpUrl;
@property (nonatomic, readonly) NSString* appServiceHttpsUrl;
@property (nonatomic, readonly) NSString* systemLanguage;

@property (nonatomic, readonly) NSString* bundleId;

@property (nonatomic, readonly) SalamaDataService* dataService;
@property (nonatomic, readonly) WebService* webService;
@property (nonatomic, readonly) SalamaUserService* userService;

@property (nonatomic, readonly) SalamaNativeService* nativeService;
@property (nonatomic, readonly) SalamaCloudService* cloudService;


+ (SalamaAppService*)singleton;

/**
 * 改变本地网页根路径
 */
- (void)switchToWebRootDirPath:(NSString*)webRootDirPath;

/**
 * 初始化App.
 */
- (void)initApp;

/**
 * 初始化App(各种资源初始化,app认证)
 * @param appId
 * @param appSecret
 */
- (void)initApp:(NSString*)appId appSecret:(NSString*)appSecret;

/**
 * 初始化App(各种资源初始化,app认证)，异步执行
 * @param appId
 * @param appSecret
 */
- (void)initAppAsync:(NSString*)appId appSecret:(NSString*)appSecret;

/**
 * 初始化App,独立服务器模式
 * @param appId
 * @param appSecret
 */
- (void)initAppInDedicatedServerMode:(NSString*)appId appSecret:(NSString*)appSecret host:(NSString*)host port:(int)port;

/**
 * 初始化App,独立服务器模式，异步执行
 * @param appId
 * @param appSecret
 */
- (void)initAppInDedicatedServerModeAsync:(NSString*)appId appSecret:(NSString*)appSecret host:(NSString*)host port:(int)port;

- (void)initAppInDebugMode:(NSString*)appId appSecret:(NSString*)appSecret;

- (void)initAppWithNoAuthenticating:(NSString*)appId appSecret:(NSString*)appSecret;


- (NSString*)getAppToken;

- (AppAuthInfo*)getAppAuthInfo;

- (AppInfo*)getAppInfo;

/**
 * 认证App，成功后可获得appToken。
 * @param appId
 * @param appSecret
 * @return AppAuthInfo
 */
- (AppAuthInfo*)authenticateApp;

/**
 * @return OpenUDID
 */
- (NSString*)getUDID;

/**
 * 取得text_xx.strings的内容，其中的xx为当前系统语言的2字符前缀。英语:en，简体汉语:zh，法语:fr，德语:de，日语:ja。
 * 其他的语言参考IOS的文档中提供的链接 http://www.loc.gov/standards/iso639-2/php/English_list.php
 * 如果系统语言对应的text_xx.strings文件不存在，则读取text_en.strings。
 * @param key text内容的key
 * @return text内容
 */
- (NSString*)getTextByKey:(NSString*)key;

/**
 * 生成dataId(可以作为本地数据库的数据主键)
 * 采用较为简单的方法：<udid> + <UTC>。方法内有锁，线程安全。但1秒只能产生1000个。
 */
- (NSString*)generateNewDataId;

/**
 * 认证AppId和AppSecret。认证失败的场合，则所有其他的WebService请求都会被拒绝
 * @return YES:成功 NO:失败
 */
- (BOOL)appLogin;

@end
