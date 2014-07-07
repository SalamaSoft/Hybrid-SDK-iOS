//
//  ResourceDownloadTaskService.m
//  SalamaDataService
//
//  Created by Liu XingGu on 12-10-4.
//
//

#import "ResourceDownloadTaskService.h"

@implementation ResourceDownloadTaskService

@synthesize resourceDownloadHandler;

@synthesize resourceFileManager;

@synthesize keyForNotificationUserObj;

- (id)init
{
    self = [super init];
    
    if(self)
    {
        NSString* strQueueName = [NSString stringWithFormat:@"%lld/downloadQueue/ResourceDownloadTaskService/cn.com.salama.www", (long long )[[NSDate date] timeIntervalSince1970]*1000];
        _downloadQueue = dispatch_queue_create([strQueueName UTF8String], NULL);
        
        self.keyForNotificationUserObj = @"result";
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_release(_downloadQueue);
}

- (dispatch_queue_t)downloadQueue
{
    return _downloadQueue;
}

-(void)addDownloadTaskWithResId:(NSString*)resId notificationName:(NSString*)notificationName
{
    if(resId == nil || resId.length == 0)
    {
        return;
    }
    
    SSLogDebug(@"addDownloadTaskWithResId:%@",resId);

    if([self.resourceFileManager isResourceFileExists:resId])
    {
        SSLogDebug(@"addDownloadTaskWithResId:%@ already exists.",resId);
        
        //notify the invoker
        if(notificationName != nil && notificationName.length > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:resId, keyForNotificationUserObj, nil]];
        }
        
        return;
    }
    
    __block NSString* resIdTmp = [resId copy];
    __block NSString* notificationNameTmp = [notificationName copy];

    dispatch_async(_downloadQueue, ^{
        //download
        NSString* resFilePath = [self.resourceFileManager getResourceFilePath:resIdTmp];
        BOOL success = [self.resourceDownloadHandler downloadByResId:resIdTmp saveTo:resFilePath];
        //NSData* data = [self.resourceDownloadHandler downloadByResId:resIdTmp];
        
        //if(data != nil && data.length > 0)
        if(success)
        {
            SSLogDebug(@"addDownloadTaskWithResId:%@ download succeeded.",resIdTmp);

            //[self.resourceFileManager saveResourceFileWithNSData:data resId:resIdTmp];
            
            //notify the invoker
            if(notificationNameTmp != nil && notificationNameTmp.length > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationNameTmp  object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:resIdTmp, keyForNotificationUserObj, nil]];
            }
        }
        else
        {
            SSLogDebug(@"addDownloadTaskWithResId:%@ download failed.",resIdTmp);
            //notify the invoker
            if(notificationNameTmp != nil && notificationNameTmp.length > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationNameTmp  object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"", keyForNotificationUserObj, nil]];
            }
        }
        
        resIdTmp = nil;
        notificationNameTmp = nil;
    });
}


@end
