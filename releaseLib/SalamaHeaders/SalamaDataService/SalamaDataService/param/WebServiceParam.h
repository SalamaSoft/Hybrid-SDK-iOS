//
//  WebServiceParam.h
//  CodeInHand
//
//  Created by XingGu Liu on 12-9-23.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceParam : NSObject<NSCopying>

/**
 * 函数名
 * <BR>为空时，采用doBasic
 */
@property (nonatomic, retain) NSString* func;

/**
 * URL
 */
@property (nonatomic, retain) NSString* url;

/**
 * method(POST或GET)
 */
@property (nonatomic, retain) NSString* method;

/**
 * 参数名列表
 */
@property (nonatomic, retain) NSArray* paramNames;

/**
 * 参数值列表
 */
@property (nonatomic, retain) NSArray* paramValues;

/**
 * 下载文件保存路径
 */
@property (nonatomic, retain) NSString* saveTo;


/**
 * 上传文件名列表
 */
@property (nonatomic, retain) NSArray* multiPartNames;

/**
 * 上传文件路径列表
 */
@property (nonatomic, retain) NSArray* multiPartFilePaths;

/**
 * 下载保存资源Id
 */
@property (nonatomic, retain) NSString* saveToResId;

/**
 * 上传文件资源Id列表
 * @return 上传文件资源Id列表
 */
@property (nonatomic, retain) NSArray* multiPartResIds;

@end
