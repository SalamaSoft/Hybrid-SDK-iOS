//
//  SalamaDataService.h
//  SalamaDataService
//
//  Created by XingGu Liu on 12-9-20.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataQueryParam.h"
#import "DBManager.h"
#import "WebService.h"

#import "ResourceDownloadHandler.h"
#import "LocalStorageService.h"
#import "ResourceDownloadTaskService.h"
#import "LocalQueryParam.h"

#import "SalamaDataServiceConfig.h"

#define DATA_SERVICE_NOTIFICATION_USER_INFO_RESULT @"result"

@class SalamaDataService;

@protocol SalamaDataServiceDelegate <NSObject>

@optional
/**
 Be invoked when webService has been done in doQuery().
 **/
- (void)queryWebServiceDidFinished:(SalamaDataService* __unsafe_unretained)dataService wsResult:(NSString* __unsafe_unretained)wsResult;

/**
 Be invoked when localStorage has been done in doQuery().
 **/
- (void)queryLocalStorageStoreDataDidFinished:(SalamaDataService* __unsafe_unretained)dataService;

/**
 Be invoked when localQuery has been done in doQuery().
 **/
- (void)queryLocalStorageQueryDataDidFinished:(SalamaDataService* __unsafe_unretained)dataService;

@end


@interface SalamaDataService : NSObject
{
    @protected
    DBManager* _dbManager;
    ResourceFileManager* _resourceFileManager;
    WebService* _webService;

    LocalStorageService* _localStorageService;
    id<ResourceDownloadHandler> _resourceDownloadHandler;
    ResourceDownloadTaskService* _resourceDownloadTaskService;

    dispatch_queue_t _queueForQueryWebService;
    dispatch_queue_t _queueForQueryLocalDB;
}

//@property (nonatomic, unsafe_unretained) id<SalamaDataServiceDelegate> delegate;

/**
 * 资源下载处理器
 */
@property (nonatomic, retain) id<ResourceDownloadHandler> resourceDownloadHandler;

/**
 * DBManager
 */
@property (nonatomic, readonly) DBManager* dbManager;

/**
 * WebService处理器
 */
@property (nonatomic, readonly) WebService* webService;

/**
 * 本地存储处理器
 */
@property (nonatomic, readonly) LocalStorageService* localStorageService;

/**
 * 资源下载任务处理器
 */
@property (nonatomic, readonly) ResourceDownloadTaskService* resourceDownloadTaskService;

/**
 * 资源管理器
 */
@property (nonatomic, readonly) ResourceFileManager* resourceFileManager;

@property (nonatomic, readonly) dispatch_queue_t queueForQueryWebService;

@property (nonatomic, readonly) dispatch_queue_t queueForQueryLocalDB;

/**
 * 初始化
 * @param config 配置
 */
- (id) initWithConfig:(SalamaDataServiceConfig*)config;

/**
 * 装载配置
 * @param config 配置
 */
- (void)loadConfig:(SalamaDataServiceConfig *)config;

/**
 Work flow:
 1. Do web service if webServiceParam is not null.
 2. Save data to local storage(Sqlite3) if lcoalStorageParam is not null.(Data Class whose name is the xml node name must exist.)
 3. Do local query if localQueryParam is not null.
 **/
/**
 * 查询数据
 * <BR>处理过程:
 * <BR>1. Do web service if webServiceParam is not null.
 * <BR>2. Save data to local storage(Sqlite3) if lcoalStorageParam is not null.(Data Class whose name is the xml node name must exist.)
 * <BR>3. Do local query if localQueryParam is not null.
 * @param queryParam 查询参数
 * @return 数据列表
 */
- (NSArray*)query:(DataQueryParam*)queryParam;

/**
 * 查询数据
 * @param queryParam 查询参数
 * @param dbDataUtil DBDataUtil
 * @return 数据列表
 */
- (NSArray*)query:(DataQueryParam*)queryParam dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 查询WebService
 * @param webServiceParam WebService参数
 * @param localStorageParam 本地存储参数
 * @return 数据列表
 */
- (NSArray*)queryWebService:(WebServiceParam*)webServiceParam localStorageParam:(LocalStorageParam*)localStorageParam;

/**
 * 查询WebService
 * @param webServiceParam WebService参数
 * @param localStorageParam 本地存储参数
 * @param dbDataUtil DBDataUtil
 * @return 数据列表
 */
- (NSArray *)queryWebService:(WebServiceParam *)webServiceParam localStorageParam:(LocalStorageParam *)localStorageParam dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 保存数据至本地数据库
 * @param localStorageParam 本地存储参数
 * @param datas 数据列表
 */
- (void)saveToLocalDB:(LocalStorageParam*)localStorageParam datas:(NSArray*)datas;

/**
 * 保存数据至本地数据库
 * @param localStorageParam 本地存储参数
 * @param datas 数据列表
 * @param dbDataUtil DBDataUtil
 */
- (void)saveToLocalDB:(LocalStorageParam*)localStorageParam datas:(NSArray*)datas dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 查询本地数据
 * @param localQueryParam 本地查询参数
 * @return 数据列表
 */
- (NSArray*)queryLocalDB:(LocalQueryParam*)localQueryParam;

/**
 * 查询本地数据
 * @param localQueryParam 本地查询参数
 * @param dbDataUtil DBDataUtil
 * @return 数据列表
 */
- (NSArray *)queryLocalDB:(LocalQueryParam *)localQueryParam dbDataUtil:(DBDataUtil*)dbDataUtil;

#pragma mark - Async methods

/**
 * 查询数据(异步-通知模式)
 * @param queryParam 查询参数
 * @param notification 通知名
 */
- (void)queryAsync:(DataQueryParam*)queryParam notification:(NSString*)notification;

/**
 * 查询WebService(异步-通知模式)
 * @param webServiceParam WebService参数
 * @param localStorageParam 本地存储参数
 * @param notification 通知名
 */
- (void)queryWebServiceAsync:(WebServiceParam*)webServiceParam localStorageParam:(LocalStorageParam*)localStorageParam notification:(NSString*)notification;

/**
 * 保存数据至本地数据库(异步-通知模式)
 * @param localStorageParam 本地存储参数
 * @param datas 数据列表
 * @param notification 通知名
 */
- (void)saveToLocalDBAsync:(LocalStorageParam*)localStorageParam datas:(NSArray*)datas notification:(NSString*)notification;

/**
 * 查询本地数据(异步-通知模式)
 * @param localQueryParam 本地查询参数
 * @param notification 通知名
 */
- (void)queryLocalDBAsync:(LocalQueryParam*)localQueryParam notification:(NSString*)notification;

/**
 * 发送通知
 * @param notification 通知名
 * @param result 数据
 */
- (void)postNotification:(NSString*)notification result:(id)result;

@end
