//
//  DataTableSetting.h
//  
//
//  Created by XingGu Liu on 12-5-8.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 目前尚未对该类型做处理。可忽略。
 * 表类型 需云同步的表
 */
extern int const DATA_TABLE_TYPE_CLOUD_DATA; 
extern int const DATA_TABLE_TYPE_USER_DATA; 
extern int const DATA_TABLE_TYPE_CUSTOMIZE; 

@interface DataTableSetting : NSObject

/**
 * 表名
 */
@property (nonatomic, retain) NSString* tableName;

/**
 * 表类型
 * 目前尚未对该类型做处理。可忽略。
 * 0:CloudDataTable 1:UserDataTable 2:Customize table
 */
@property (nonatomic, assign) int tableType;

/**
 * 主键信息
 * <BR>以逗号分隔多个主键的格式. 示例: "id,num,type"
 * @return 主键信息
 */
@property (nonatomic, retain) NSString* primaryKeys;

@end
