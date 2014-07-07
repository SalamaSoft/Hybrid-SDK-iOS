//
//  SalamaCloudFileService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-7-31.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaCloudFileService.h"
#import "SalamaAppService.h"
#import "ASIHTTPUtil.h"

#define EASY_APP_FILE_SERVICE @"com.salama.easyapp.service.FileService"
//#define DOWNLOAD_NOTIFICATION_RESULT_NAME @"result"

@implementation SalamaCloudFileService

static SalamaCloudFileService* _singleton;

+ (SalamaCloudFileService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaCloudFileService alloc] init];
    });
    
    return _singleton;
}

- (FileOperateResult *)downloadByFileId:(NSString *)fileId
{
    return [self downloadByFileId:fileId saveToFilePath:[[SalamaAppService singleton].webService.resourceFileManager.fileStorageDirPath stringByAppendingPathComponent:fileId]];
}

- (FileOperateResult *)downloadByFileId:(NSString *)fileId saveToFilePath:(NSString *)saveToFilePath
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    NSString* downloadUrl = [[SalamaAppService singleton].webService doGet:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"fileId", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_FILE_SERVICE, @"getFileDownloadUrl", authTicket, fileId, nil]];
    
    FileOperateResult* result = [[FileOperateResult alloc] init];
    result.fileId = [fileId copy];
    result.success = 0;
    
    if(downloadUrl == nil || downloadUrl.length == 0)
    {
        //failed
        return result;
    }
    
    //download from OSS
    //NSString* fileSavePath = [dirPath stringByAppendingPathComponent:fileId];
    BOOL success = [ASIHTTPUtil doGetMethodDownloadWithEncodedUrl:downloadUrl downloadToPath:saveToFilePath timeoutSeconds:[SalamaAppService singleton].webService.requestTimeoutSeconds];
    
    if(success)
    {
        //success
        result.success = 1;
    }
    
    return result;
}

- (FileOperateResult *)addFile:(NSString *)filePath aclRestrictUserRead:(NSString *)aclRestrictUserRead aclRestrictUserUpdate:(NSString *)aclRestrictUserUpdate aclRestrictUserDelete:(NSString *)aclRestrictUserDelete
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    
    NSString* resultXml = [[SalamaAppService singleton].webService doUpload:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"aclRestrictUserRead", @"aclRestrictUserUpdate", @"aclRestrictUserDelete",  nil] paramValues:[NSArray arrayWithObjects:EASY_APP_FILE_SERVICE, @"addFile", authTicket, aclRestrictUserRead==nil?@"":aclRestrictUserRead, aclRestrictUserUpdate==nil?@"":aclRestrictUserUpdate, aclRestrictUserDelete==nil?@"":aclRestrictUserDelete, nil] multiPartNames:[NSArray arrayWithObjects:@"file", nil] multiPartFilePaths:[NSArray arrayWithObjects:filePath, nil]];
    
    return [SimpleMetoXML stringToObject:resultXml dataType:[FileOperateResult class]];
}

- (FileOperateResult *)updateByFileId:(NSString *)fileId filePath:(NSString *)filePath
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    
    NSString* resultXml = [[SalamaAppService singleton].webService doUpload:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"fileId", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_FILE_SERVICE, @"updateFile", authTicket, fileId, nil] multiPartNames:[NSArray arrayWithObjects:@"file", nil] multiPartFilePaths:[NSArray arrayWithObjects:filePath, nil]];
    
    return [SimpleMetoXML stringToObject:resultXml dataType:[FileOperateResult class]];
}

- (FileOperateResult *)deleteByFileId:(NSString *)fileId
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    NSString* resultXml = [[SalamaAppService singleton].webService doGet:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"fileId", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_FILE_SERVICE, @"deleteFile", authTicket, fileId, nil]];
    
    return [SimpleMetoXML stringToObject:resultXml dataType:[FileOperateResult class]];
}

- (void)addDownloadTaskWithFileId:(NSString *)fileId notificationName:(NSString *)notificationName
{
    NSString* filePath = [[SalamaAppService singleton].dataService.resourceFileManager getResourceFilePath:fileId];
    [self addDownloadTaskWithFileId:fileId saveToFilePath:filePath notificationName:notificationName];
}

- (void)addDownloadTaskWithFileId:(NSString *)fileId saveToFilePath:(NSString *)saveToFilePath notificationName:(NSString *)notificationName
{
    if(fileId == nil || fileId.length == 0 || saveToFilePath == nil || saveToFilePath.length == 0)
    {
        return;
    }
    
    SSLogDebug(@"addDownloadTaskWithFileId:%@", fileId);
    
    if([[NSFileManager defaultManager] fileExistsAtPath:saveToFilePath])
    {
        SSLogDebug(@"addDownloadTaskWithFileId:%@ already exists.", fileId);
        
        //notify the invoker
        if(notificationName != nil && notificationName.length > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[fileId copy], DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil]];
        }
        
        return;
    }
    
    __block NSString* resIdTmp = [fileId copy];
    __block NSString* notificationNameTmp = [notificationName copy];
    
    dispatch_async([[SalamaAppService singleton].dataService.resourceDownloadTaskService downloadQueue], ^{
        //download
        FileOperateResult* result = [self downloadByFileId:resIdTmp saveToFilePath:saveToFilePath];
        
        if(result != nil && result.success)
        {
            SSLogDebug(@"addDownloadTaskWithFileId:%@ download succeeded.", resIdTmp);
            
            //notify the invoker
            if(notificationNameTmp != nil && notificationNameTmp.length > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationNameTmp  object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:resIdTmp, DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil]];
            }
        }
        else
        {
            SSLogDebug(@"addDownloadTaskWithFileId:%@ download failed.",resIdTmp);
            //notify the invoker
            if(notificationNameTmp != nil && notificationNameTmp.length > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationNameTmp  object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"", DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT, nil]];
            }
        }
        
        resIdTmp = nil;
        notificationNameTmp = nil;
    });
    
}

@end
