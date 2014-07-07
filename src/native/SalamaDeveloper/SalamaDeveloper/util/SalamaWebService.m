//
//  SalamaWebService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-7-29.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaWebService.h"

#import "HttpClient.h"
#import "SalamaWebServiceUtil.h"

@implementation SalamaWebService

//@synthesize requestTimeoutSeconds = _requestTimeoutSeconds;

//@synthesize resourceFileManager;

/*
 static WebService* _singleton = nil;
 
 +(WebService*)singleton
 {
 static dispatch_once_t createSingleton;
 dispatch_once(&createSingleton, ^{
 _singleton = [[WebService alloc] init];
 });
 
 return _singleton;
 }
 */

- (NSString*)doBasic:(NSString *)url isPost:(BOOL)isPost paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues
{
    return [SalamaWebServiceUtil doBasicMethod:url isDownload:NO isPostMethod:isPost paramNames:paramNames paramValues:paramValues requestTimeoutInterval:_requestTimeoutSeconds];
}

- (NSString *)doGet:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues
{
    return [SalamaWebServiceUtil doBasicMethod:url isDownload:NO isPostMethod:NO paramNames:paramNames paramValues:paramValues requestTimeoutInterval:_requestTimeoutSeconds];
}

- (NSString *)doPost:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues
{
    return [SalamaWebServiceUtil doBasicMethod:url isDownload:NO isPostMethod:YES paramNames:paramNames paramValues:paramValues requestTimeoutInterval:_requestTimeoutSeconds];
}

- (NSData *)doDownload:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues
{
    return [SalamaWebServiceUtil doBasicMethod:url isDownload:YES isPostMethod:YES paramNames:paramNames paramValues:paramValues requestTimeoutInterval:_requestTimeoutSeconds];
}

- (BOOL)doDownloadToSave:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues saveTo:(NSString *)saveTo
{
    NSData* data = [SalamaWebServiceUtil doBasicMethod:url isDownload:YES isPostMethod:YES paramNames:paramNames paramValues:paramValues requestTimeoutInterval:_requestTimeoutSeconds];
    
    if(data == nil)
    {
        return NO;
    }
    else
    {
        [data writeToFile:saveTo atomically:YES];
        return YES;
    }
}

- (NSString *)doUpload:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartNames:(NSArray *)multiPartNames multiPartFilePaths:(NSArray *)multiPartFilePaths
{
    NSMutableArray* multiPartArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < multiPartNames.count; i++)
    {
        [multiPartArray addObject:[[FilePart alloc] initWithFile:[NSURL fileURLWithPath:[multiPartFilePaths objectAtIndex:i]] withName:[multiPartNames objectAtIndex:i] compressFile:NO]];
    }
    
    return [SalamaWebServiceUtil doMultipartMethod:url isDownload:NO paramNames:paramNames paramValues:paramValues filePartValues:multiPartArray requestTimeoutInterval:_requestTimeoutSeconds];
}

- (NSData *)doUploadAndDownload:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartNames:(NSArray *)multiPartNames multiPartFilePaths:(NSArray *)multiPartFilePaths
{
    NSMutableArray* multiPartArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < multiPartNames.count; i++)
    {
        [multiPartArray addObject:[[FilePart alloc] initWithFile:[NSURL fileURLWithPath:[multiPartFilePaths objectAtIndex:i]] withName:[multiPartNames objectAtIndex:i] compressFile:NO]];
    }
    
    return [SalamaWebServiceUtil doMultipartMethod:url isDownload:NO paramNames:paramNames paramValues:paramValues filePartValues:multiPartArray requestTimeoutInterval:_requestTimeoutSeconds];
}

- (BOOL)doUploadAndDownloadToSave:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartNames:(NSArray *)multiPartNames multiPartFilePaths:(NSArray *)multiPartFilePaths saveTo:(NSString *)saveTo
{
    NSData* data = [self doUploadAndDownload:url paramNames:paramNames paramValues:paramValues multiPartNames:multiPartNames multiPartFilePaths:multiPartFilePaths];
    
    if(data == nil)
    {
        return NO;
    }
    else
    {
        [data writeToFile:saveTo atomically:YES];
        return YES;
    }
}

#pragma  mark - download or upload resource file
- (BOOL)doDownloadResource:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues saveToResId:(NSString *)saveToResId
{
    return [self doDownloadToSave:url paramNames:paramNames paramValues:paramValues saveTo:[self.resourceFileManager getResourceFilePath:saveToResId]];
}

- (NSString *)doUploadResource:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartNames:(NSArray *)multiPartNames multiPartResIds:(NSArray *)multiPartResIds
{
    NSMutableArray* multiPartFilePaths = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < multiPartResIds.count; i++)
    {
        [multiPartFilePaths addObject:[self.resourceFileManager getResourceFilePath:[multiPartResIds objectAtIndex:i]]];
    }
    
    return [self doUpload:url paramNames:paramNames paramValues:paramValues multiPartNames:multiPartNames multiPartFilePaths:multiPartFilePaths];
}

- (BOOL)doUploadAndDownloadResource:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartNames:(NSArray *)multiPartNames multiPartResIds:(NSArray *)multiPartResIds saveToResId:(NSString *)saveToResId
{
    NSMutableArray* multiPartFilePaths = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < multiPartResIds.count; i++)
    {
        [multiPartFilePaths addObject:[self.resourceFileManager getResourceFilePath:[multiPartResIds objectAtIndex:i]]];
    }
    
    return [self doUploadAndDownloadToSave:url paramNames:paramNames paramValues:paramValues multiPartNames:multiPartNames multiPartFilePaths:multiPartFilePaths saveTo:[self.resourceFileManager getResourceFilePath:saveToResId]];
}

@end
