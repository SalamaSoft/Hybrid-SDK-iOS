//
//  InvokeMsg.h
//  Workmate
//
//  Created by XingGu Liu on 12-2-12.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/parser.h>

#import "SSLog.h"

@interface InvokeMsg : NSObject

/**
 * 目标对象名
 */
@property (nonatomic, retain) NSString *target;

/**
 * 方法名
 */
@property (nonatomic, retain) NSString *method;

/**
 * 参数列表
 */
@property (nonatomic, retain) NSArray *params;

/**
 * 操作成功时回调函数名
 */
@property (nonatomic, retain) NSString *callBackWhenSucceed;

/**
 * 操作出错时回调函数名
 */
@property (nonatomic, retain) NSString *callBackWhenError;

/**
 * 是否异步方式执行(已经废弃，设置任何值不会有效果)
 */
@property (nonatomic, assign) bool isAsync;

/**
 * 返回值保存变量名
 */
@property (nonatomic, retain) NSString* returnValueKeeper;

/**
 * 取得返回值保存变量范围
 */
@property (nonatomic, retain) NSString* keeperScope;

/**
 * notification名。如果非空，则忽略callBackWhenSucceed以及callBackWhenError。调用完成时，将发送通知，调用的返回值通过通知的数据参数传递。
 */
@property (nonatomic, retain) NSString* notification;

/**
 * 创建InvokeMsg
 * @param xml InvokeMsg的Xml内容
 * @return InvokeMsg或NSArray<InvokeMsg>
 */
+(id) invokeMsgWithXml:(NSString*)xml;

/**
 * 解码URL字符串
 * @param urlStr URL字符串
 * @return 解码后的URL字符串
 */
+(NSString *)decodeURLString:(NSString*)str;

@end
