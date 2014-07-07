//
//  SalamaAppService.m
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaAppService.h"

#import "TimeUtil.h"
#import "SimpleMetoXML.h"
#import "MD5Util.h"
#import "ASIHTTPUtil.h"
#import "OpenUDID.h"

@implementation AppAuthInfo

@synthesize appId;
@synthesize appToken;
@synthesize expiringTime;

@end

@implementation AppInfo

@synthesize appServiceHttpUrl;
@synthesize appServiceHttpsUrl;

@synthesize myAppServiceHttpUrl;
@synthesize myAppServiceHttpsUrl;

@end

@interface SalamaAppService()

+ (NSString *)getUDIDFromDevice;

- (void)initAppHost;

- (void)initAppHostInDedicatedServerMode;

- (void)storeAppAuthInfoWithAppId:(NSString*)appId appAuthInfo:(AppAuthInfo*)appAuthInfo;
- (AppAuthInfo*)getStoredAppAuthInfoWithAppId:(NSString*)appId;

- (BOOL)isAppAuthInfoValid:(AppAuthInfo*)appAuthInfo;

- (BOOL)checkAppLogin;

- (AppAuthInfo*)appLoginByAppSecret:(NSString*)appSecret;

- (AppAuthInfo*)appLoginByAppToken:(NSString*)appToken;

@end

/*
 #define TEXT_FILE_NAME_CHINESE @"text_ch"
 #define TEXT_FILE_NAME_ENGLISH @"text_en"
 #define TEXT_FILE_NAME_FRENCH @"text_fr"
 #define TEXT_FILE_NAME_JAPANESE @"text_de"
 #define TEXT_FILE_NAME_GERMAN @"text_ja"
 #define TEXT_FILE_NAME_KOREAN @"text_ko"
 
 typedef enum LanguageType {
 LanguageChinese,
 LanguageEnglish,
 LanguageFrance,
 LanguageGerman,
 LanguageJapanese,
 LanguageKorean,
 LanguageOther
 } LanguageType;
 */

#define CLOUD_DATA_SERVICE_URI @"/cloudDataService.do"
#define EASY_APP_SERVICE_URI @"/easyApp/cloudDataService.do"
#define EASY_APP_AUTH_SERVICE @"com.salama.easyapp.service.AppAuthService"

#define DEFAULT_WEB_PACKAGE_NAME @"html"
#define DEFAULT_HTTP_REQUEST_TIMEOUT_SECONDS 30
#define SALAMA_SERVICE_NAME @"salama"

@implementation SalamaAppService

@synthesize appId = _appId;
@synthesize appServiceHttpUrl = _easyAppServiceHttpUrl;
@synthesize appServiceHttpsUrl = _easyAppServiceHttpsUrl;
@synthesize systemLanguage = _systemLanguage;

@synthesize bundleId = _bundleId;

@synthesize dataService = _dataService;
@synthesize webService = _webService;
@synthesize userService;

@synthesize nativeService;
@synthesize cloudService;

- (SalamaUserService *)userService
{
    return [SalamaUserService singleton];
}

- (SalamaNativeService *)nativeService
{
    return [SalamaNativeService singleton];
}

- (SalamaCloudService *)cloudService
{
    return [SalamaCloudService singleton];
}

static SalamaAppService* _singleton;

+ (SalamaAppService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaAppService alloc] init];
    });
    
    return _singleton;
}

- (NSString *)getAppToken
{
    if(_appAuthInfo == nil || _appAuthInfo.appToken == nil)
    {
        return @"";
    }
    else
    {
        return [_appAuthInfo.appToken copy];
    }
}

- (AppAuthInfo *)getAppAuthInfo
{
    return _appAuthInfo;
}

- (AppInfo *)getAppInfo
{
    return _appInfo;
}

- (id)init
{
    if(self = [super init])
    {
        _udid = [SalamaAppService getUDIDFromDevice];
        _udidRemovedHyphen = [_udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        _bundleId = [[NSBundle mainBundle].bundleIdentifier copy];
        NSLog(@"bundleId:%@", _bundleId);
//        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
//        NSLog(@"version:%@", version);
        
        _appInfo = [[AppInfo alloc] init];
    
        [self checkTextFile];
        
        if([self checkWebPackageExists:DEFAULT_WEB_PACKAGE_NAME])
        {
            [self initObjsWithWebPackageName:DEFAULT_WEB_PACKAGE_NAME];
        }
        else
        {
            [self initObjsForMultiWebRootMode];
        }
        
    }
    
    return self;
}

- (BOOL)checkWebPackageExists:(NSString*)webPackageName
{
    NSString* htmlZipPath = [[NSBundle mainBundle] pathForResource:webPackageName ofType:@"zip"];
    
    //check if the zip file exists
    if(htmlZipPath == nil || ![[NSFileManager defaultManager] fileExistsAtPath:htmlZipPath])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)checkTextFile
{
    NSString* systemLanguagePrefix = [self getSystemLanguagePrefix];
    
    _textFileName = [NSString stringWithFormat:@"text_%@", systemLanguagePrefix];

    //check file in bundle
    NSString* filePath = [[NSBundle mainBundle] pathForResource:_textFileName ofType:@"strings"];
    if(filePath == nil || ![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        SSLogInfo(@"%@.strings does not exist. Change to use text_en.strings", _textFileName);
        _textFileName = @"text_en";
    }
}

- (NSString*)getSystemLanguagePrefix
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    _systemLanguage = [languages objectAtIndex:0];
    SSLogInfo(@"_systemLanguage:%@", _systemLanguage);
    
    NSString* systemLanguagePrefix = [_systemLanguage substringToIndex:2];
    return systemLanguagePrefix;
}

- (void)initApp
{
    _notUseEasyAppService = YES;
    [self initWebService];
}

- (void)initApp:(NSString *)appId appSecret:(NSString *)appSecret
{
    [self initAppWithNoAuthenticating:appId appSecret:appSecret];
    
    [self authenticateApp];
}

- (void)initAppAsync:(NSString *)appId appSecret:(NSString *)appSecret
{
    [self initAppWithNoAuthenticating:appId appSecret:appSecret];

    dispatch_async(_dataService.queueForQueryWebService, ^{
        [self authenticateApp];
    });
}

- (void)initAppInDedicatedServerMode:(NSString *)appId appSecret:(NSString *)appSecret host:(NSString *)host port:(int)port
{
    _dedicatedServerMode = YES;
    _easyAppServiceHttpPort = port;
    _easyAppServiceHttpsPort = 443;
    _easyAppServiceHttpHost = [NSString stringWithFormat:@"http://%@:%d", host, _easyAppServiceHttpPort];
    _easyAppServiceHttpsHost = [NSString stringWithFormat:@"https://%@:%d", host, _easyAppServiceHttpsPort];
    
    [self initAppWithNoAuthenticating:appId appSecret:appSecret];
    
    if(appId != nil && appSecret != nil)
    {
        [self authenticateApp];
    }
}

- (void)initAppInDedicatedServerModeAsync:(NSString *)appId appSecret:(NSString *)appSecret host:(NSString *)host port:(int)port
{
    _dedicatedServerMode = YES;

    [self initAppWithNoAuthenticating:appId appSecret:appSecret];
    
    if(appId != nil && appSecret != nil)
    {
        dispatch_async(_dataService.queueForQueryWebService, ^{
            [self authenticateApp];
        });
    }
}

- (void)initAppInDebugMode:(NSString *)appId appSecret:(NSString *)appSecret
{
    [self initAppWithNoAuthenticating:appId appSecret:appSecret];

    _easyAppServiceHttpHost = @"127.0.0.1:8080";
    _easyAppServiceHttpUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, EASY_APP_SERVICE_URI];
    _easyAppServiceHttpsUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, EASY_APP_SERVICE_URI];
    
    _myAppServiceHttpUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, [NSString stringWithFormat:@"/%@%@", appId, CLOUD_DATA_SERVICE_URI]];
    _myAppServiceHttpsUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, [NSString stringWithFormat:@"/%@%@", appId, CLOUD_DATA_SERVICE_URI]];

    _appInfo.appServiceHttpUrl = _easyAppServiceHttpUrl;
    _appInfo.appServiceHttpsUrl = _easyAppServiceHttpsUrl;
    _appInfo.myAppServiceHttpUrl = _myAppServiceHttpUrl;
    _appInfo.myAppServiceHttpsUrl = _myAppServiceHttpsUrl;
    
    [self authenticateApp];
}

- (void)initAppWithNoAuthenticating:(NSString *)appId appSecret:(NSString *)appSecret
{
    _appId = [appId copy];
    _appSecret = [appSecret copy];
    
    if(_dedicatedServerMode)
    {
        [self initAppHostInDedicatedServerMode];
    }
    else
    {
        [self initAppHost];
    }
}

- (void)initAppHost
{
    //Servie Host ----------------
    NSRange range;
    range.location = 0;
    range.length = 4;
    NSString* serverDivisionNum = [_appId substringWithRange:range];
    _easyAppServiceHostPrefix = [@"dev" stringByAppendingFormat:@"%@", serverDivisionNum];
    
    range.location = 4;
    range.length = 2;
    NSString* serverNumHex = [_appId substringWithRange:range];
    unsigned long serverNumLong = strtoul([serverNumHex UTF8String], NULL, 16);
    unsigned int serverNum = (unsigned int)serverNumLong;
    _easyAppServiceHttpPort = 30000 + serverNum;
    _easyAppServiceHttpsPort = 40000 + serverNum;
    
    _easyAppServiceHttpHost = [NSString stringWithFormat:@"%@.salama.com.cn:%d", _easyAppServiceHostPrefix, _easyAppServiceHttpPort];
    _easyAppServiceHttpsHost = [NSString stringWithFormat:@"%@.salama.com.cn:%d", _easyAppServiceHostPrefix, _easyAppServiceHttpsPort];
    _easyAppServiceHttpUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, EASY_APP_SERVICE_URI];
    _easyAppServiceHttpsUrl = [NSString stringWithFormat:@"https://%@%@", _easyAppServiceHttpsHost, EASY_APP_SERVICE_URI];
    
    _appInfo.appServiceHttpUrl = _easyAppServiceHttpUrl;
    _appInfo.appServiceHttpsUrl = _easyAppServiceHttpsUrl;
    
}

- (void)initAppHostInDedicatedServerMode
{
    _easyAppServiceHttpUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, EASY_APP_SERVICE_URI];
    _easyAppServiceHttpsUrl = [NSString stringWithFormat:@"https://%@%@", _easyAppServiceHttpsHost, EASY_APP_SERVICE_URI];
    _myAppServiceHttpUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpHost, [NSString stringWithFormat:@"/%@%@", _appId, CLOUD_DATA_SERVICE_URI]];
    _myAppServiceHttpsUrl = [NSString stringWithFormat:@"http://%@%@", _easyAppServiceHttpsHost, [NSString stringWithFormat:@"/%@%@", _appId, CLOUD_DATA_SERVICE_URI]];
    _appInfo.myAppServiceHttpUrl = _myAppServiceHttpUrl;
    _appInfo.myAppServiceHttpsUrl = _myAppServiceHttpsUrl;
}

+ (NSString *)getUDIDFromDevice
{
    /* Deprecated
    CFUUIDRef deviceId = CFUUIDCreate(NULL);
    
    CFStringRef deviceIdStringRef = CFUUIDCreateString(NULL,deviceId);
    CFRelease(deviceId);
    
    NSString *deviceIdString = [NSString stringWithString:(__bridge NSString *)deviceIdStringRef];
    CFRelease(deviceIdStringRef);
    
    return deviceIdString;
    */
    
    return [OpenUDID value];
}

- (AppAuthInfo *)authenticateApp
{
    //login
    BOOL loginSuccess = [self checkAppLogin];
    if(!loginSuccess)
    {
        NSLog(@"SalamaAppService app login failed");
    }

    //_appInfo.appId = _appAuthInfo.appId;
    //_appInfo.appToken = _appAuthInfo.appToken;
    //_appInfo.expiringTime = _appAuthInfo.expiringTime;
    
    return _appAuthInfo;
}

- (void)initObjsWithWebPackageName:(NSString *)webPackageName
{
    //configure log level
    SetSSLogLevel(SSLogLevelDebug);
    
    //DEBUG
    [WebController setDebugMode:NO];
    
    //init webmanager(include extract html) ---------------
    [WebManager initWithWebPackageName:webPackageName localWebLocationType:LocalWebLocationTypeDocuments];

    [self initServicesWithIsMultiWebRootMode:NO];
    
    // Register Service ----------------------------------
    [[WebManager webController].nativeService registerService:SALAMA_SERVICE_NAME service:self];
}

- (void)initObjsForMultiWebRootMode
{
    //configure log level
    SetSSLogLevel(SSLogLevelDebug);
    
    //DEBUG
    [WebController setDebugMode:NO];
    
    //init webmanager(include extract html) ---------------
    NSArray* specialPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* webBaseDirPath = [specialPaths objectAtIndex:0];
    NSString* defaultHtmlRootPath = [webBaseDirPath stringByAppendingPathComponent:DEFAULT_WEB_PACKAGE_NAME];
    [WebManager initWithExistingWebRootPath:defaultHtmlRootPath];

    [self initServicesWithIsMultiWebRootMode:YES];
    
    // Register Service ----------------------------------
    [[WebManager webController].nativeService registerService:SALAMA_SERVICE_NAME service:self];
}

- (void)switchToWebRootDirPath:(NSString*)webRootDirPath
{
    [[WebManager webController] switchToWebRootDirPath:webRootDirPath];
    
    [self initServicesWithIsMultiWebRootMode:YES];
}

/**
 * MultiWebRootMode Only for SalamaBox for test purpos,
 */
- (void)initServicesWithIsMultiWebRootMode:(BOOL)isMultiWebRootMode
{
    //init dataService ------------------------------------
    SalamaDataServiceConfig* config = [[SalamaDataServiceConfig alloc] init];
    
    config.httpRequestTimeout = DEFAULT_HTTP_REQUEST_TIMEOUT_SECONDS;
    config.resourceStorageDirPath = [[[WebManager webController] webRootDirPath] stringByAppendingPathComponent:@"res"];
    config.dbName = @"localDB";
    if(isMultiWebRootMode)
    {
        config.dbDirPath = [[[WebManager webController] webRootDirPath] stringByAppendingPathComponent:@".SalamaData"];
    }
    else
    {
        config.dbDirPath = [DBManager defaultDbDirPath:LocalDBLocationTypeDocuments];
    }
    
    _dataService = [[SalamaDataService alloc] initWithConfig:config];
    //_dataService.resourceDownloadHandler = [[MerchantImageResourceDownloadHandler alloc] init];
    
    [self initWebService];
}

- (void)initWebService
{
    if(_notUseEasyAppService)
    {
        _webService = [[WebService alloc] init];
    }
    else
    {
        _webService = [[SalamaWebService alloc] init];
    }
    
    _webService.requestTimeoutSeconds = DEFAULT_HTTP_REQUEST_TIMEOUT_SECONDS;
    _webService.resourceFileManager = _dataService.resourceFileManager;
}

- (void)storeAppAuthInfoWithAppId:(NSString *)appId appAuthInfo:(AppAuthInfo *)appAuthInfo
{
    NSString* appAuthInfoXml = [SimpleMetoXML objectToString:appAuthInfo];
    SSLogDebug(@"appAuthInfoXml:%@", appAuthInfoXml);
    [[NSUserDefaults standardUserDefaults] setObject:appAuthInfoXml forKey:appId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (AppAuthInfo *)getStoredAppAuthInfoWithAppId:(NSString *)appId
{
    NSString* appAuthInfoXml = [[NSUserDefaults standardUserDefaults] objectForKey:appId];
    SSLogDebug(@"appAuthInfoXml:%@", appAuthInfoXml);
    if(appAuthInfoXml == nil)
    {
        return nil;
    }
    else
    {
        return [SimpleMetoXML stringToObject:appAuthInfoXml dataType:[AppAuthInfo class]];
    }
}

- (BOOL)appLogin
{
    AppAuthInfo* appAuthInfo = [self appLoginByAppSecret:_appSecret];
    
    if(appAuthInfo != nil)
    {
        if([self isAppAuthInfoValid:appAuthInfo])
        {
            if(_appAuthInfo == nil)
            {
                _appAuthInfo = [[AppAuthInfo alloc] init];
                _appAuthInfo.appId = appAuthInfo.appId;
            }
            
            _appAuthInfo.appToken = appAuthInfo.appToken;
            _appAuthInfo.expiringTime = appAuthInfo.expiringTime;

            return YES;
        }
    }
    
    return NO;
}

- (BOOL)checkAppLogin
{
    BOOL loginSuccess = NO;
 
    _appAuthInfo = [self getStoredAppAuthInfoWithAppId:_appId];
    
    if(_appAuthInfo != nil && (_appAuthInfo.expiringTime - 120000) >= [TimeUtil getCurrentTime] && _appAuthInfo.appToken != nil)
    {
        //token尚未过期
        AppAuthInfo* appAuthInfo = [self appLoginByAppToken:_appAuthInfo.appToken];
        if(appAuthInfo != nil)
        {
            _appAuthInfo.appToken = appAuthInfo.appToken;
            _appAuthInfo.expiringTime = appAuthInfo.expiringTime;
            
            if([self isAppAuthInfoValid:appAuthInfo])
            {
                loginSuccess = YES;
            }
            
        }
    }

    if(!loginSuccess)
    {
        AppAuthInfo* appAuthInfo = [self appLoginByAppSecret:_appSecret];
        
        if(appAuthInfo != nil)
        {
            if([self isAppAuthInfoValid:appAuthInfo])
            {
                if(_appAuthInfo == nil)
                {
                    _appAuthInfo = [[AppAuthInfo alloc] init];
                    _appAuthInfo.appId = appAuthInfo.appId;
                }
                
                _appAuthInfo.appToken = appAuthInfo.appToken;
                _appAuthInfo.expiringTime = appAuthInfo.expiringTime;
                
                loginSuccess = YES;
            }
        }
        else
        {
            if(_appAuthInfo == nil)
            {
                _appAuthInfo = [[AppAuthInfo alloc] init];
            }
        }
    }
    
    if(!loginSuccess)
    {
        if(_appAuthInfo != nil)
        {
            _appAuthInfo.appToken = @"";
            _appAuthInfo.expiringTime = 0;
        }
    }

    if(_appAuthInfo != nil)
    {
        [self storeAppAuthInfoWithAppId:_appId appAuthInfo:_appAuthInfo];
    }
    
    return loginSuccess;
}

- (AppAuthInfo*)appLoginByAppToken:(NSString *)appToken
{
    NSString* appAuthInfoXml = [_dataService.webService doGet:_easyAppServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appId", @"appToken", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_AUTH_SERVICE, @"appLoginByToken", _appId, appToken, nil]];
    if(appAuthInfoXml == nil || appAuthInfoXml.length == 0)
    {
        return nil;
    }
    else
    {
        return [SimpleMetoXML stringToObject:appAuthInfoXml dataType:[AppAuthInfo class]];
    }
}

- (AppAuthInfo *)appLoginByAppSecret:(NSString *)appSecret
{
    long long utcTime = [TimeUtil getCurrentTime];
    NSString* utcTimeStr = [NSString stringWithFormat:@"%lld", utcTime];
    NSString* utcTimeMD5 = [MD5Util md5String:utcTimeStr];
    NSString* secretMD5 = [MD5Util md5String:appSecret];
    NSString* secretMD5MD5 = [MD5Util md5String:[NSString stringWithFormat:@"%@%@", secretMD5, utcTimeMD5]];
    
    NSString* appAuthInfoXml = [ASIHTTPUtil doGetMethodWithUrl:_easyAppServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appId", @"appSecretMD5MD5", @"utcTime", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_AUTH_SERVICE, @"appLogin", _appId, secretMD5MD5, utcTimeStr, nil] encoding:NSUTF8StringEncoding timeoutSeconds:_webService.requestTimeoutSeconds];
    //NSString* appAuthInfoXml = [_dataService.webService doGet:_easyAppServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appId", @"appSecretMD5MD5", @"utcTime", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_AUTH_SERVICE, @"appLogin", _appId, secretMD5MD5, utcTimeStr, nil]];
    if(appAuthInfoXml == nil || appAuthInfoXml.length == 0)
    {
        return nil;
    }
    else
    {
        return [SimpleMetoXML stringToObject:appAuthInfoXml dataType:[AppAuthInfo class]];
    }
}

- (BOOL)isAppAuthInfoValid:(AppAuthInfo *)appAuthInfo
{
    if(appAuthInfo == nil)
    {
        return NO;
    }
    else
    {
        if(![_appId isEqualToString:appAuthInfo.appId])
        {
            return NO;
        }
        if(appAuthInfo.appToken == nil)
        {
            return NO;
        }
        if(appAuthInfo.expiringTime <= [TimeUtil getCurrentTime])
        {
            return NO;
        }

        return YES;
    }
    
}

- (NSString *)getUDID
{
    return [_udid copy];
}

-(NSString*)getTextByKey:(NSString*)key
{
    return NSLocalizedStringFromTable(key, _textFileName, @"");
}

- (NSString *)generateNewDataId
{
    [_lockForNewDataId lock];
    
    @try {
        [NSThread sleepForTimeInterval:0.001];
        
        long long curTime = [TimeUtil getCurrentTime];
        return [NSString stringWithFormat:@"%@%016llx", _udidRemovedHyphen, curTime];
    }
    @finally {
        [_lockForNewDataId unlock];
    }
}
@end
