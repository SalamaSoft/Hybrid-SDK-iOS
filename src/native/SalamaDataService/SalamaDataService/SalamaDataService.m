//
//  SalamaDataService.m
//  SalamaDataService
//
//  Created by XingGu Liu on 12-9-20.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "SalamaDataService.h"
#import "WebService.h"

#import "SimpleMetoXML.h"

#import "ExtraIndexManager.h"

@interface SalamaDataService(PrivateMethod)

- (void)initObjs;

@end

@implementation SalamaDataService

//@synthesize delegate;
@synthesize resourceDownloadHandler = _resourceDownloadHandler;
@synthesize dbManager = _dbManager;
@synthesize webService = _webService;
@synthesize localStorageService = _localStorageService;
@synthesize resourceDownloadTaskService = _resourceDownloadTaskService;
@synthesize resourceFileManager = _resourceFileManager;

@synthesize queueForQueryLocalDB = _queueForQueryLocalDB;
@synthesize queueForQueryWebService = _queueForQueryWebService;

- (ResourceDownloadTaskService *)resourceDownloadTaskService
{
    return _resourceDownloadTaskService;
}

- (void)setResourceDownloadHandler:(id<ResourceDownloadHandler>)handler
{
    _resourceDownloadHandler = handler;
    _resourceDownloadTaskService.resourceDownloadHandler = handler;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        [self initObjs];
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_queueForQueryWebService);
    dispatch_release(_queueForQueryLocalDB);
    
    _webService.resourceFileManager = nil;
    _webService = nil;
    
    _resourceDownloadTaskService.resourceFileManager = nil;
    _resourceDownloadTaskService.resourceDownloadHandler = nil;
    _resourceDownloadTaskService = nil;
    
    _localStorageService = nil;
}

- (id)initWithConfig:(SalamaDataServiceConfig *)config
{
    self = [super init];
    
    if(self)
    {
        [self initObjs];

        [self loadConfig:config];
    }
    
    return self;
}

- (void)initObjs
{
    _webService = [[WebService alloc] init];
    _resourceDownloadTaskService = [[ResourceDownloadTaskService alloc] init];
    _resourceDownloadTaskService.keyForNotificationUserObj = DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT;
    
    _localStorageService = [[LocalStorageService alloc] init];
    
    NSString* strQueueNameForQueryLocalDB = [NSString stringWithFormat:@"%lld/queueForQueryLocalDB/ResourceDownloadTaskService/cn.com.salama.www", (long long )[[NSDate date] timeIntervalSince1970]*1000];
    _queueForQueryLocalDB = dispatch_queue_create([strQueueNameForQueryLocalDB UTF8String], DISPATCH_QUEUE_SERIAL);
    
    NSString* strQueueNameForQueryWebService = [NSString stringWithFormat:@"%lld/queueForQueryWebService/ResourceDownloadTaskService/cn.com.salama.www", (long long )[[NSDate date] timeIntervalSince1970]*1000];
    _queueForQueryWebService = dispatch_queue_create([strQueueNameForQueryWebService UTF8String], NULL);
    
}

- (void)loadConfig:(SalamaDataServiceConfig *)config
{
    _webService.requestTimeoutSeconds = config.httpRequestTimeout;
    
    _dbManager = nil;
    _dbManager = [[DBManager alloc] initWithDbName:config.dbName dbDirPath:config.dbDirPath];
    
    _resourceFileManager = nil;
    _resourceFileManager = [[ResourceFileManager alloc] initWithStorageDirPath:config.resourceStorageDirPath];

    _webService.resourceFileManager = _resourceFileManager;
    
    _resourceDownloadTaskService.resourceFileManager = _resourceFileManager;
}

- (NSArray *)query:(DataQueryParam *)queryParam
{
    DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];
    
    @try {
        //query
        return [self query:queryParam dbDataUtil:dbDataUtil];
    }
    @finally {
        [dbDataUtil close];
    }
}

- (NSArray *)query:(DataQueryParam *)queryParam dbDataUtil:(DBDataUtil *)dbDataUtil
{
    if(queryParam == nil)
    {
        return nil;
    }
    
    //query through web service and sotre the result to localDB
    NSArray* wsResult = [self queryWebService:queryParam.webService localStorageParam:queryParam.localStorage dbDataUtil:dbDataUtil];
    if(queryParam.localQuery == nil)
    {
        return wsResult;
    }
    
    //query from local db ---
    return [self queryLocalDB:queryParam.localQuery dbDataUtil:dbDataUtil];
}

- (NSArray *)queryWebService:(WebServiceParam *)webServiceParam localStorageParam:(LocalStorageParam *)localStorageParam
{
    DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];
    
    @try {
        //query from web service ---
        return [self queryWebService:webServiceParam localStorageParam:localStorageParam dbDataUtil:dbDataUtil];
    }
    @finally {
        [dbDataUtil close];
    }
}

- (NSArray *)queryWebService:(WebServiceParam *)webServiceParam localStorageParam:(LocalStorageParam *)localStorageParam dbDataUtil:(DBDataUtil*)dbDataUtil
{
    if(webServiceParam == nil)
    {
        return nil;
    }
    
    BOOL isPost = YES;
    
    if([[webServiceParam.method uppercaseString] isEqualToString:@"GET"])
    {
        isPost = NO;
    }
    
    NSString* wsResult = [_webService doBasic:webServiceParam.url isPost:isPost paramNames:webServiceParam.paramNames paramValues:webServiceParam.paramValues];
    
    //parse xml result to object
    NSArray* wsResultObj = [SimpleMetoXML stringToObject:wsResult];
    
    //save data to local db ---
    if(localStorageParam != nil
       && localStorageParam.tableName != nil
       && localStorageParam.tableName.length > 0)
    {
        //store data into local db
        [self saveToLocalDB:localStorageParam datas:wsResultObj dbDataUtil:dbDataUtil];
    }
    
    return wsResultObj;
}

- (void)saveToLocalDB:(LocalStorageParam*)localStorageParam datas:(NSArray*)datas
{
    DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];
    
    @try {
        //store datas ---
        [_localStorageService storeDataToTable:localStorageParam.tableName datas:datas extraIndexNames:localStorageParam.extraIndexNames extraIndexValues:localStorageParam.extraIndexValues dbDataUtil:dbDataUtil];
    }
    @finally {
        [dbDataUtil close];
    }
}

- (void)saveToLocalDB:(LocalStorageParam*)localStorageParam datas:(NSArray*)datas dbDataUtil:(DBDataUtil*)dbDataUtil
{
    if(datas != nil)
    {
        [_localStorageService storeDataToTable:localStorageParam.tableName datas:datas extraIndexNames:localStorageParam.extraIndexNames extraIndexValues:localStorageParam.extraIndexValues dbDataUtil:dbDataUtil];
    }
}

- (NSArray *)queryLocalDB:(LocalQueryParam *)localQueryParam
{
    DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];
    
    @try {
        //query from local db ---
        return [self queryLocalDB:localQueryParam dbDataUtil:dbDataUtil];
    }
    @finally {
        [dbDataUtil close];
    }
}


- (NSArray *)queryLocalDB:(LocalQueryParam *)localQueryParam dbDataUtil:(DBDataUtil*)dbDataUtil
{
    if(localQueryParam == nil)
    {
        SSLogDebug(@"localQueryParam is nil");
        return nil;
    }
    
    NSArray* dataList = nil;
    
    SSLogDebug(@"localQueryParam.sql:%@", localQueryParam.sql);
    
    if(localQueryParam.sql != nil && localQueryParam.sql.length > 0)
    {
        //get data
        dataList = [dbDataUtil.sqliteUtil findDataList:localQueryParam.sql dataType:NSClassFromString(localQueryParam.dataClass)];
        
        //download resource file
        if(localQueryParam.resourceNames != nil
           && localQueryParam.resourceNames.length > 0
           && self.resourceDownloadHandler != nil)
        {
            NSArray* resNameArray = [localQueryParam.resourceNames componentsSeparatedByString:@","];
            NSString* resNameTmp = nil;
            NSString* resIdTmp = nil;
            id dataTmp = nil;
            int i,j;
            if(resNameArray.count > 0)
            {
                for(i = 0; i < dataList.count; i++)
                {
                    dataTmp = [dataList objectAtIndex:i];
                    for(j = 0; j < resNameArray.count; j++)
                    {
                        resNameTmp = [resNameArray objectAtIndex:j];
                        resIdTmp = [dataTmp objectForKey:resNameTmp];
                        
                        if(resIdTmp != nil && resIdTmp.length > 0)
                        {
                            [_resourceDownloadTaskService addDownloadTaskWithResId:resIdTmp notificationName:localQueryParam.resourceDownloadNotification];
                        }
                    }
                    
                }
            }
        }
    }
    
    return dataList;
}

#pragma mark - Async methods
- (void)queryAsync:(DataQueryParam *)queryParam notification:(NSString *)notification
{
    __block DataQueryParam* queryParamTmp = [queryParam copy];
    __block NSString* queryNotificationTmp = [notification copy];
    
    dispatch_async(_queueForQueryWebService, ^{
        NSArray* result = nil;
        
        DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];
        
        @try {
            result = [self query:queryParamTmp dbDataUtil:dbDataUtil];
        }
        @finally {
            [dbDataUtil close];
            dbDataUtil = nil;
        }
        
        NSDictionary* userInfo = nil;
        if(result != nil)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:result, DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:queryNotificationTmp  object:self userInfo:userInfo];
        
        queryParamTmp = nil;
        queryNotificationTmp = nil;
    });
}

- (void)queryWebServiceAsync:(WebServiceParam *)webServiceParam localStorageParam:(LocalStorageParam *)localStorageParam notification:(NSString *)notification
{
    __block WebServiceParam* webServiceParamTmp = [webServiceParam copy];
    __block LocalStorageParam* localStorageParamTmp = [localStorageParam copy];
    __block NSString* queryNotificationTmp = [notification copy];
    
    dispatch_async(_queueForQueryWebService, ^{
        NSArray* result = nil;
        DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];

        @try {
            result = [self queryWebService:webServiceParamTmp localStorageParam:localStorageParamTmp dbDataUtil:dbDataUtil];
        }
        @finally {
            [dbDataUtil close];
            dbDataUtil = nil;
        }
        
        
        NSDictionary* userInfo = nil;
        if(result != nil)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:result, DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:queryNotificationTmp  object:self userInfo:userInfo];
        
        webServiceParamTmp = nil;
        localStorageParamTmp = nil;
        queryNotificationTmp = nil;
    });
}

- (void)saveToLocalDBAsync:(LocalStorageParam*)localStorageParam datas:(NSArray*)datas notification:(NSString*)notification
{
    __block LocalStorageParam* localStorageParamTmp = [localStorageParam copy];
    __block NSString* queryNotificationTmp = [notification copy];
    
    dispatch_async(_queueForQueryWebService, ^{
        [self saveToLocalDB:localStorageParam datas:datas];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:queryNotificationTmp  object:self userInfo:nil];
        
        localStorageParamTmp = nil;
        queryNotificationTmp = nil;
    });
}

- (void)queryLocalDBAsync:(LocalQueryParam *)localQueryParam notification:(NSString *)notification
{
    __block LocalQueryParam* localQueryParamTmp = [localQueryParam copy];
    __block NSString* queryNotificationTmp = [notification copy];
    
    dispatch_async(_queueForQueryLocalDB, ^{
        NSArray* result = nil;
        DBDataUtil* dbDataUtil = [_dbManager createNewDBDataUtil];

        @try {
            result = [self queryLocalDB:localQueryParamTmp dbDataUtil:dbDataUtil];
        }
        @finally {
            [dbDataUtil close];
            dbDataUtil = nil;
        }
        
        NSDictionary* userInfo = nil;
        if(result != nil)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:result, DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:queryNotificationTmp object:self userInfo:userInfo];
        
        localQueryParamTmp = nil;
        queryNotificationTmp = nil;
    });
}

- (void)postNotification:(NSString*)notification result:(id)result
{
    NSDictionary* userInfo = nil;
    if(result != nil)
    {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:result, DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self userInfo:userInfo];
}

@end
