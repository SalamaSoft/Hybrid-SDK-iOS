//
//  WebService.h
//  CodeInHands
//
//  Created by XingGu Liu on 12-9-20.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HttpClient.h"

@interface WebServiceUtil : NSObject

/**
 * 执行RESTFull Web Service
 * @param url URL
 * @param isDownload 是否下载文件
 * @param isPostMethod 是否POST方式
 * @param paramNames 参数列表(NSArray<String>)
 * @param paramValues 参数值列表(NSArray<String>)
 * @param requestTimeoutInterval 请求超时时间(单位:毫秒)
 * @return 返回值(普通方式下返回字符串，下载文件的场合返回NSData)
 */
+(id) doBasicMethod:(NSString*)url isDownload:(BOOL)isDownload isPostMethod:(BOOL)isPostMethod paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues requestTimeoutInterval:(int)requestTimeoutInterval;

/**
 * 执行RESTFull Web Service。有上传的文件(Multipart-form)
 * @param url URL
 * @param isDownload 是否下载文件
 * @param isPostMethod 是否POST方式
 * @param paramNames 参数列表(NSArray<String>)
 * @param paramValues 参数值列表(NSArray<String>)
 * @param filePartValues 上传的文件列表(NSArray<FilePart>)
 * @param requestTimeoutInterval 请求超时时间(单位:毫秒)
 * @return 返回值(普通方式下返回字符串，下载文件的场合返回NSData)
 */
+(id) doMultipartMethod:(NSString*)url isDownload:(BOOL)isDownload paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues filePartValues:(NSArray*)filePartValues requestTimeoutInterval:(int)requestTimeoutInterval;

@end
