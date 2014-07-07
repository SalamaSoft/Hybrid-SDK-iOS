//
//  WebManager.h
//  Workmate
//
//  Created by XingGu Liu on 12-2-8.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "DBDataUtil.h"
#import "WebController.h"

@interface WebManager : NSObject

/**
 * 初始化本地页面
 * @param webPackageName 本地页面压缩包名
 * @param localWebLocationType 本地页面存储位置类型
 */
+ (void)initWithWebPackageName:(NSString*)webPackageName localWebLocationType:(LocalWebLocationType)localWebLocationType;

/**
 * 初始化(本地网页目录已存在，无需解压zip)
 * @param existingWebRootPath 本地网页根路径
 * @return WebController
 */
+ (void)initWithExistingWebRootPath:(NSString*)existingWebRootPath;

/**
 * 取得webController
 * @return webController
 */
+(WebController*) webController;

/*
+(void) releaseAll;

+(DBDataUtil*)defaultDBDataUtil;

+(DBDataUtil*)createNewDBDataUtil;

+(DBDataUtil*)createNewDBDataUtilWithDbFilePath:(NSString*)dbFilePath;
*/

@end
