//
//  LocalStorageParam.h
//  CodeInHand
//
//  Created by XingGu Liu on 12-9-24.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorageParam : NSObject<NSCopying>

/**
 * 表名
 */
@property (nonatomic, retain) NSString* tableName;

/**
 * 数据类型
 * <BR>如果为空，则采用tableName
 */
@property (nonatomic, retain) NSString* dataClass;

/**
 * 外部索引字段名列表
 */
@property (nonatomic, retain) NSArray* extraIndexNames;

/**
 * 外部索引字段值列表
 */
@property (nonatomic, retain) NSArray* extraIndexValues;

@end
