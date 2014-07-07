//
//  SalamaCloudService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SalamaCloudFileService.h"
#import "SalamaCloudSqlService.h"

@interface SalamaCloudService : NSObject
{
}

/**
 * 取得SalamaCloudFileService实例
 * @return SalamaCloudFileService实例
 */
@property(nonatomic, readonly) SalamaCloudFileService* fileService;

/**
 * 取得SalamaCloudSqlService实例
 * @return SalamaCloudSqlService实例
 */
@property(nonatomic, readonly) SalamaCloudSqlService* sqlService;

/**
 * 取得实例(singleton)
 * @return SalamaCloudService实例
 */
+ (SalamaCloudService*)singleton;

@end
