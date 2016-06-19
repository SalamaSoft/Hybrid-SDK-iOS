//
//  BaseAppService.m
//  SalamaBaseApp
//
//  Created by XingGu Liu on 16/6/17.
//  Copyright © 2016年 Salama Soft. All rights reserved.
//

#import "BaseAppService.h"

#import "TimeUtil.h"
#import "OpenUDID.h"

#import "SalamaDataServiceConfig.h"

@implementation BaseAppService

@synthesize udid = _udid;
@synthesize bundleId = _bundleId;
@synthesize systemLanguage = _systemLanguage;
@synthesize dataService = _dataService;
@synthesize webService = _webService;
@synthesize nativeService = _nativeService;

static bool _debugMode = false;

+ (bool)isDebugMode
{
    return _debugMode;
}

+(void)setDebugMode:(bool)isDebug
{
    _debugMode = isDebug;
    
    if(_debugMode)
    {
        //DEBUG
        SetSSLogLevel(SSLogLevelDebug);
        
        [WebController setDebugMode:YES];
    }
    else
    {
        SetSSLogLevel(SSLogLevelError);
        
        [WebController setDebugMode:NO];
    }

}

- (id)initWithUdid:(NSString *)udid httpRequestTimeoutSeconds:(int)httpRequestTimeoutSeconds webPackageDirName:(NSString *)webPackageDirName webResourceDirName:(NSString *)webResourceDirName
{
    if(self = [super init])
    {
        _udid = udid;
        _httpRequestTimeoutSeconds = httpRequestTimeoutSeconds;
        _webPackageDirName = webPackageDirName;
        _webResourceDirName = webResourceDirName;

        _dataIdSeq = 0;
        
        _bundleId = [[NSBundle mainBundle].bundleIdentifier copy];
        
        SSLogInfo(@"_udid:%@", _udid);
        SSLogInfo(@"_httpRequestTimeoutSeconds:%@", _httpRequestTimeoutSeconds);
        SSLogInfo(@"_webPackageDirName:%@", _webPackageDirName);
        SSLogInfo(@"_webResourceDirName:%@", _webResourceDirName);
        SSLogInfo(@"_bundleId:%@", _bundleId);

        [self checkTextFile];
        
        [self initWebController];
        
        [self initServices];
    }
    
    return self;
}

- (NSString *)generateNewDataId
{
    long long curTime = [TimeUtil getCurrentTime];
    return [NSString stringWithFormat:@"%@%016llx%04x", _udid, curTime, (unsigned)([self increSeq] & 0xFFFF)];
}

-(NSString*)getTextByKey:(NSString*)key
{
    return NSLocalizedStringFromTable(key, _textFileName, @"");
}


- (NSInteger)increSeq
{
    [_lockForNewDataId lock];
    
    @try {
        if(_dataIdSeq == NSIntegerMax)
        {
            _dataIdSeq = 0;
        } else {
            _dataIdSeq ++;
        }
        
        return _dataIdSeq;
    }
    @finally {
        [_lockForNewDataId unlock];
    }
}

- (void)initWebController
{
    [WebManager initWithWebPackageName:_webPackageDirName localWebLocationType:LocalWebLocationTypeDocuments];
}

- (void)initServices
{
    _dataService = [[SalamaDataService alloc] initWithConfig:[self makeDataServiceConfig]];
    
    _nativeService = [[SalamaNativeService alloc] initWithDataService:_dataService];

    _webService = [[WebService alloc] init];
    _webService.requestTimeoutSeconds = _httpRequestTimeoutSeconds;
    _webService.resourceFileManager = _dataService.resourceFileManager;
}


- (SalamaDataServiceConfig*)makeDataServiceConfig
{
    SalamaDataServiceConfig* config = [[SalamaDataServiceConfig alloc] init];
    
    config.httpRequestTimeout = _httpRequestTimeoutSeconds;
    config.resourceStorageDirPath = [[[WebManager webController] webRootDirPath] stringByAppendingPathComponent:@"res"];
    config.dbDirPath = [DBManager defaultDbDirPath:LocalDBLocationTypeDocuments];
    
    if([_webPackageDirName isEqualToString:DEFAULT_WEB_PACKAGE_DIR])
    {
        config.dbName = [NSString stringWithFormat:@"localDB_%@", _webPackageDirName];
    }
    else
    {
        config.dbName = @"localDB";
    }

    return config;
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

@end
