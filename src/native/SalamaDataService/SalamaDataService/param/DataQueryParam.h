//
//  DataQueryParam.h
//  CodeInHand
//
//  Created by XingGu Liu on 12-9-24.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WebServiceParam.h"
#import "LocalStorageParam.h"
#import "LocalQueryParam.h"

@interface DataQueryParam : NSObject<NSCopying>

/**
 * WebService参数
 */
@property (nonatomic, retain) WebServiceParam* webService;

/**
 * 本地存储参数
 */
@property (nonatomic, retain) LocalStorageParam* localStorage;

/**
 * 本地查询参数
 */
@property (nonatomic, retain) LocalQueryParam* localQuery;

@end
