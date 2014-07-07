//
//  SalamaCloudFileService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-7-31.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileOperateResult.h"

@interface SalamaCloudFileService : NSObject

+ (SalamaCloudFileService*)singleton;


/**
 * 下载文件(文件保存至默认的资源文件目录下:"/html/res/")
 * @param fileId
 * @return 文件操作结果
 */
- (FileOperateResult*)downloadByFileId:(NSString*)fileId;

/**
 * 下载文件(文件保存至指定的文件路径)
 * @param fileId
 * @param saveToFilePath 文件保存路径
 * @return 文件操作结果
 */
- (FileOperateResult*)downloadByFileId:(NSString*)fileId saveToFilePath:(NSString*)saveToFilePath;

/**
 * 增加文件(上传)
 * @param filePath
 * @param aclRestrictUserRead 指定拥有读权限的用户。
 * (多个用户id逗号分割，则指定的用户可以操作。该值未指定或空则仅仅数据创建者可以操作。'%'代表任何用户可以操作),
 * @param aclRestrictUserUpdate 指定拥有更新权限的用户
 * @param aclRestrictUserDelete 指定拥有删除权限的用户
 * @return FileOperateResult(其中的fileId为服务器端分配的序列号)
 */
- (FileOperateResult*)addFile:(NSString*)filePath aclRestrictUserRead:(NSString*)aclRestrictUserRead aclRestrictUserUpdate:(NSString*)aclRestrictUserUpdate aclRestrictUserDelete:(NSString*)aclRestrictUserDelete;

/**
 * 更新文件
 * @param fileId
 * @param filePath 上传文件路径
 * @return FileOperateResult
 */
- (FileOperateResult*)updateByFileId:(NSString*)fileId filePath:(NSString*)filePath;

/**
 * 删除文件
 * @param fileId
 * @return FileOperateResult
 */
- (FileOperateResult*)deleteByFileId:(NSString*)fileId;

/**
 * 添加下载任务(自动保存至res目录)
 * @param resId 资源Id
 * @param notificationName 通知名
 */
- (void)addDownloadTaskWithFileId:(NSString*)fileId notificationName:(NSString*)notificationName;

/**
 * 添加下载任务(保存至指定文件路径)
 * @param resId 资源Id
 * @param saveToFilePath 文件保存路径
 * @param notificationName 通知名
 */
- (void)addDownloadTaskWithFileId:(NSString*)fileId saveToFilePath:(NSString*)saveToFilePath notificationName:(NSString*)notificationName;
@end
