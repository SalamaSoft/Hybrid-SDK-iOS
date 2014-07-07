//
//  LocalService.h
//  Workmate
//
//  Created by XingGu Liu on 12-2-8.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "InvokeMsg.h"

@interface NativeService : NSObject
{
    NSMutableDictionary *_targetDict;
    
    //UIViewController *_thisView;
}

//@property (nonatomic, retain) UIViewController *thisView;


/**
 * 解析指令
 * @param cmd 指令内容
 * @return InvokeMsg或NSArray<InvokeMsg>
 */
+(id) parseNativeServiceCmd:(NSString*)cmd;

/**
 * 注册service
 * @param serviceName service名称
 * @param service service实例
 */
-(void)registerService:(NSString*)serviceName service:(id)service;

/**
 * 调用
 * @param targetName 目标对象
 * @param methodName 方法名
 * @param params 参数列表
 * @param thisView thisView
 * @return 调用返回值
 */
-(id) invoke:(NSString*)targetName method:(NSString*)methodName params:(NSArray*)params thisView:(id)thisView;



/************************ DEBUG ****************************/
/*
-(long long)testMethod1;

-(long long)testMethod2:(NSString*)p1 p2:(bool)p2 p3:(short)p3;

-(long long)testMethodInfo:(char)p1 p2:(bool)p2 p3:(short)p3 p4:(int)p4 p5:(long)p5 p6:(long long)p6 
                        p7:(float)p7 p8:(double)p8 p9:(NSString*)p9 p10:(NSNumber*)p10 p11:(NSDecimalNumber*)p11 p12:(NSDate*)p12 p13:(NSData*)p13;

+(long long)testStaticMethodInfo:(char)p1 p2:(bool)p2 p3:(short)p3 p4:(int)p4 p5:(long)p5 p6:(long long)p6 
                              p7:(float)p7 p8:(double)p8 p9:(NSString*)p9 p10:(NSNumber*)p10 p11:(NSDecimalNumber*)p11 p12:(NSDate*)p12 p13:(NSData*)p13;
*/
@end
