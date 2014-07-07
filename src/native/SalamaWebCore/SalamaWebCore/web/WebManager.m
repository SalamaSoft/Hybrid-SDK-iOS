//
//  WebManager.m
//  Workmate
//
//  Created by XingGu Liu on 12-2-8.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "WebManager.h"

#define SALAMA_INTERNAL_VERSION @"1.3.1"
#define SALAMA_INTERNAL_VERSION_DATE @"2014/03/24"

@interface WebManager(PrivateMethod)

//+(void)test;

//+(void)checkDbDir:(NSString*)dbDirPath;


@end

static WebController* _webController;
//static NSString* _dbFilePath;
//static DBDataUtil* _dbDataUtil;

//static CloudDataUtil* _cloudDataUtil;
//static CloudDataService* _cloudDataService;
//static ResourceFileManager* _resourceFileManager;

@implementation WebManager

+(WebController*) webController
{
    return _webController;
}

+(void) initWithWebPackageName:(NSString*)webPackageName localWebLocationType:(LocalWebLocationType)localWebLocationType
{
    NSLog(@"SalamaIOS %@ %@", SALAMA_INTERNAL_VERSION, SALAMA_INTERNAL_VERSION_DATE);
    
    //init web
    _webController = [[WebController alloc] init:webPackageName localWebLocationType:localWebLocationType];
 
    /*
    //check db dir and mkdir if it does not exist
    [WebManager checkDbDir:dbDirPath];
    
    //init cloudDataUtil
    if((dbName != nil) && (dbDirPath != nil))
    {
        //init dbDataUtil
        _dbFilePath = [dbDirPath stringByAppendingPathComponent:dbName];
        SqliteUtil* newSqliteUtil = [[SqliteUtil alloc] init:_dbFilePath];
        [newSqliteUtil open];
        _dbDataUtil = [[DBDataUtil alloc] init:newSqliteUtil];

        //init cloudDataUtil
        //_cloudDataUtil = [[CloudDataUtil alloc] init:_dbDataUtil appId:appId userId:nil];
        
    }
    */
    
    /*
     //init resourceFileManager
     NSString* resourceFileManagerStorageDir = [[_webController webRootDirPath] stringByAppendingPathComponent:resourceFileRelativeDirName];
     
     _resourceFileManager = [[ResourceFileManager alloc] init:resourceFileManagerStorageDir];

    _cloudDataService = [[CloudDataService alloc] init];
    _cloudDataService.cloudDataServiceURL = [cloudDataServiceUrl copy];
    
    [_webController.nativeService registerService:@"cloudDataUtil" service:_cloudDataUtil];
    [_webController.nativeService registerService:@"cloudDataService" service:_cloudDataService];
    [_webController.nativeService registerService:@"resourceFileManager" service:_resourceFileManager];
     */
    
    //[self test];
}

+ (void)initWithExistingWebRootPath:(NSString *)existingWebRootPath
{
    NSLog(@"SalamaIOS %@ %@", SALAMA_INTERNAL_VERSION, SALAMA_INTERNAL_VERSION_DATE);
    
    //init web
    _webController = [[WebController alloc] initWithExistingWebRootPath:existingWebRootPath];
}

/*
+(DBDataUtil *)createNewDBDataUtil
{
    SqliteUtil* newSqliteUtil = [[SqliteUtil alloc] init:_dbFilePath];
    [newSqliteUtil open];
    
    DBDataUtil* newDbDataUtil = [[DBDataUtil alloc] init:newSqliteUtil];
    
    return newDbDataUtil;
}

+(DBDataUtil*)createNewDBDataUtilWithDbFilePath:(NSString*)dbFilePath
{
    SqliteUtil* newSqliteUtil = [[SqliteUtil alloc] init:dbFilePath];
    [newSqliteUtil open];
    DBDataUtil* newDbDataUtil = [[DBDataUtil alloc] init:newSqliteUtil];

    return newDbDataUtil;
}

+(DBDataUtil*)defaultDBDataUtil
{
    return _dbDataUtil;
}
 +(void)releaseAll
 {
 _webController = nil;
 
 [_dbDataUtil.sqliteUtil close];
 
 _dbDataUtil = nil;
 
 //_cloudDataUtil = nil;
 }
*/
/*
+(CloudDataUtil*) cloudDataUtil
{
    return _cloudDataUtil;
}

+(CloudDataService*) cloudDataService
{
    return _cloudDataService;
}

+(ResourceFileManager*) resourceFileManager
{
    return _resourceFileManager;
}
*/
/*
+(void)test
{
    GetMethod* urlGet = [[GetMethod alloc] init];
    
    [urlGet addParameter:@"com.salama.server.getgifts.resource.service.OneResourceService" withName:@"serviceType"];
    [urlGet addParameter:@"1" withName:@"resourceId"];
    NSURL * destURL = [NSURL URLWithString:@"http://192.168.1.101:8080/MoreGifts/downloadService.do"];
    
    HttpResponse* response = [urlGet executeSynchronouslyAtURL:destURL];

    NSString* savePath = [[_webController toRealPath:@"resourceFile"] stringByAppendingPathComponent:@"1"];
    
    NSLog(@"savePath:%@", savePath);

    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:savePath contents:response.responseData attributes:nil];
    
//    NSFileHandle* file = [NSFileHandle fileHandleForWritingAtPath:savePath];
//    [file writeData:response.responseData];
//    [file closeFile];
}
*/

/*
+(void)checkDbDir:(NSString*)dbDirPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL isDir;
    
    //check if target dir exists    
    if([fm fileExistsAtPath:dbDirPath isDirectory:&isDir])
    {
        if(!isDir)
        {
            //dir exists but not dir, then delete it
            [fm removeItemAtPath:dbDirPath error:nil];
            
            [fm createDirectoryAtPath:dbDirPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    else
    {
        [fm createDirectoryAtPath:dbDirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    fm = nil;
}
*/

@end

/*
@implementation UIViewController (WebManagerUIViewController)
-(void) viewWillAppear:(BOOL)animated
{
    UIWebView* webView = [self valueForKey:@"webView"];
    if(webView != nil)
    {
        [WebManager setThisView:self webView:webView];
    }
}
@end
 */
