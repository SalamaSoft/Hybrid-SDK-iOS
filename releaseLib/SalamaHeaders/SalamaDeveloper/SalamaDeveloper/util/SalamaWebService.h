//
//  SalamaWebService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-7-29.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResourceFileManager.h"
#import "WebService.h"

@interface SalamaWebService : WebService
{
//    @private
//    int _requestTimeoutSeconds;
}

/**
 * 请求timeout秒数
 */
//@property (nonatomic, assign) int requestTimeoutSeconds;

/**
 * 资源管理器
 */
//@property (nonatomic, unsafe_unretained) ResourceFileManager* resourceFileManager;

//+(WebService*)singleton;

/**
 * 执行基本方法
 * @param url URL
 * @param isPost 是否POST
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @return 返回结果
 */
- (NSString*)doBasic:(NSString*)url isPost:(BOOL)isPost paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues;

/**
 * 执行GET方法
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @return 返回结果
 */
- (NSString*)doGet:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues;

/**
 * 执行POST方法
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @return 返回结果
 */
- (NSString*)doPost:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues;

/**
 * 执行下载(POST方式)
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @return 返回结果(文件内容)
 */
- (NSData*)doDownload:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues;

/**
 * 执行下载(POST方式)
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param saveTo 保存路径
 * @return 是否成功
 */
- (BOOL)doDownloadToSave:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues saveTo:(NSString*)saveTo;

/**
 * 执行上传
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param multiPartNames 上传文件名列表
 * @param multiPartFilePaths 上传文件路径列表
 * @return 返回结果
 */
- (NSString*)doUpload:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues multiPartNames:(NSArray*)multiPartNames multiPartFilePaths:(NSArray*)multiPartFilePaths;

/**
 * 执行上传并下载文件
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param multiPartNames 上传文件名列表
 * @param multiPartFilePaths 上传文件路径列表
 * @return 返回结果(文件内容)
 */
- (NSData*)doUploadAndDownload:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues multiPartNames:(NSArray*)multiPartNames multiPartFilePaths:(NSArray*)multiPartFilePaths;

/**
 * 执行上传并下载文件
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param multiPartNames 上传文件名列表
 * @param multiPartFilePaths 上传文件路径列表
 * @param saveTo 下载文件保存路径
 * @return 是否成功
 */
- (BOOL)doUploadAndDownloadToSave:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues multiPartNames:(NSArray*)multiPartNames multiPartFilePaths:(NSArray*)multiPartFilePaths saveTo:(NSString*)saveTo;

#pragma  mark - download or upload resource file
/**
 * 下载资源文件
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param saveToResId 保存用资源Id
 * @return 是否成功
 */
- (BOOL)doDownloadResource:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues saveToResId:(NSString*)saveToResId;

/**
 * 上传资源文件
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param multiPartNames 上传文件名列表
 * @param multiPartResIds 上传文件资源Id
 * @return 返回结果
 */
- (NSString*)doUploadResource:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues multiPartNames:(NSArray*)multiPartNames multiPartResIds:(NSArray*)multiPartResIds;

/**
 * 上传资源文件并下载
 * @param url URL
 * @param paramNames 参数名列表
 * @param paramValues 参数值列表
 * @param multiPartNames 上传文件名列表
 * @param multiPartResIds 上传文件资源Id
 * @param saveToResId 下载文件保存用资源Id
 * @return 是否成功
 */
- (BOOL)doUploadAndDownloadResource:(NSString*)url paramNames:(NSArray*)paramNames paramValues:(NSArray*)paramValues multiPartNames:(NSArray*)multiPartNames multiPartResIds:(NSArray*)multiPartResIds saveToResId:(NSString*)saveToResId;

@end
