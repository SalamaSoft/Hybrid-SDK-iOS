//
//  ResourceDownloadTaskService.h
//  SalamaDataService
//
//  Created by Liu XingGu on 12-10-4.
//
//

#import <Foundation/Foundation.h>

#import "ResourceDownloadHandler.h"
#import "ResourceFileManager.h"

#import "SSLog.h"

@interface ResourceDownloadTaskService : NSObject
{
    @private
    dispatch_queue_t _downloadQueue;
}

/**
 * 资源下载处理器
 */
@property (nonatomic, unsafe_unretained) id<ResourceDownloadHandler> resourceDownloadHandler;

/**
 * ResourceFileManager
 */
@property (nonatomic, unsafe_unretained) ResourceFileManager* resourceFileManager;

/**
 * 通知中的用户数据的存放名
 */
@property (nonatomic, retain) NSString* keyForNotificationUserObj;

/**
 * 取得下载队列
 * @return 下载队列
 */
- (dispatch_queue_t)downloadQueue;

/**
 * 添加下载任务
 * @param resId 资源Id
 * @param notificationName 通知名
 */
- (void)addDownloadTaskWithResId:(NSString*)resId notificationName:(NSString*)notificationName;

@end
