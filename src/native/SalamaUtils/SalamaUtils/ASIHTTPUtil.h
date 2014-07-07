//
//  ASIHTTPUtil.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-13.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultiPartFile : NSObject

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* filePath;

- (id) initWithName:(NSString*)theName filePath:(NSString*)theFilePath;

@end

@interface ASIHTTPUtil : NSObject

/**
 * 调用RESTFull Web Service(GET方式)
 * @param url
 * @param paramNames 参数名列表(NSArray<String>)
 * @param paramValues 参数值列表(NSArray<String>)
 * @param encoding 字符集编码
 * @param timeoutSeconds 请求的超时事件(单位:秒)
 * @return
 */
+ (NSString*)doGetMethodWithUrl:(NSString*)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues encoding:(NSStringEncoding)encoding timeoutSeconds:(double)timeoutSeconds;

/**
 * 调用RESTFull Web Service(GET方式)，下载文件。
 * @param url
 * @param paramNames 参数名列表(NSArray<String>)
 * @param paramValues 参数值列表(NSArray<String>)
 * @param encoding 字符集编码
 * @param downloadToPath 下载文件保存路径
 * @param timeoutSeconds 请求的超时事件(单位:秒)
 * @return YES:成功 NO:失败
 */
+ (BOOL)doGetMethodDownloadWithUrl:(NSString*)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues encoding:(NSStringEncoding)encoding downloadToPath:(NSString*)downloadToPath timeoutSeconds:(double)timeoutSeconds;

/**
 * 通过已经百分号编码的URL(GET方式)，下载文件。
 * @param url
 * @param downloadToPath 下载文件保存路径
 * @param timeoutSeconds 请求的超时事件(单位:秒)
 * @return YES:成功 NO:失败
 */
+ (BOOL)doGetMethodDownloadWithEncodedUrl:(NSString*)url downloadToPath:(NSString*)downloadToPath timeoutSeconds:(double)timeoutSeconds;

/**
 * 调用RESTFull Web Service(POST方式)
 * @param url
 * @param paramNames 参数名列表(NSArray<String>)
 * @param paramValues 参数值列表(NSArray<String>)
 * @param multiPartFiles 上传文件列表(NSArray<MultiPartFile>)
 * @param encoding 字符集编码
 * @param timeoutSeconds 请求的超时事件(单位:秒)
 * @return
 */
+ (NSString*)doPostMethodWithUrl:(NSString*)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartFiles:(NSArray*)multiPartFiles encoding:(NSStringEncoding)encoding timeoutSeconds:(double)timeoutSeconds;

/**
 * 调用RESTFull Web Service(POST方式)，下载文件
 * @param url
 * @param paramNames 参数名列表(NSArray<String>)
 * @param paramValues 参数值列表(NSArray<String>)
 * @param multiPartFiles 上传文件列表(NSArray<MultiPartFile>)
 * @param encoding 字符集编码
 * @param downloadToPath 下载文件保存路径
 * @param timeoutSeconds 请求的超时事件(单位:秒)
 * @return
 */
+ (BOOL)doPostMethodDownloadWithUrl:(NSString*)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartFiles:(NSArray*)multiPartFiles encoding:(NSStringEncoding)encoding downloadToPath:(NSString*)downloadToPath timeoutSeconds:(double)timeoutSeconds;

@end
