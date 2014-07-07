//
//  ExtraIndexManager.h
//  SalamaDataService
//
//  Created by Liu XingGu on 12-9-29.
//
//

#import <Foundation/Foundation.h>

#import "DBDataUtil.h"

@interface ExtraIndexManager : NSObject

/**
 * 取得外部索引表名
 * @param dataTableName 数据表名
 * @return 外部索引表名
 */
+ (NSString*)getExtraIndexTableNameByDataTableName:(NSString*)dataTableName;

/**
 * 创建外部索引表
 * @param dataTableName 数据表名
 * @param dataPrimaryKeys 数据表主键(逗号分隔)
 * @param extraIndexes 外部索引字段(逗号分隔)
 * @param dataClass 数据类型
 * @param dbDataUtil DBDataUtil实例
 */
+ (void)createExtraIndexTableWithDataTableName:(NSString*)dataTableName dataPrimaryKeys:(NSString*)dataPrimaryKeys extraIndexes:(NSString*)extraIndexes  dataClass:(Class)dataClass dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 删除外部索引表名
 * @param dataTableName 数据表名
 * @param dbDataUtil DBDataUtil实例
 */
+ (void)dropExtraIndexTableByDataTableName:(NSString*)dataTableName dbDataUtil:(DBDataUtil *)dbDataUtil;

/**
 * 插入外部索引记录
 * @param dataTableName 数据表名
 * @param datas 数据列表
 * @param extraIndexNames 外部索引字段名(逗号分隔)
 * @param extraIndexValues 外部索引值(逗号分隔)
 * @param dbDataUtil DBDataUtil实例
 */
+ (void)insertExtraIndexWithDataTableName:(NSString*)dataTableName datas:(NSArray*)datas extraIndexNames:(NSArray*)extraIndexNames extraIndexValues:(NSArray*)extraIndexValues dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 删除外部索引记录
 * @param dataTableName 数据表名
 * @param datas 数据列表
 * @param extraIndexNames 外部索引字段名(逗号分隔)
 * @param extraIndexValues 外部索引值(逗号分隔)
 * @param dbDataUtil DBDataUtil实例
 */
+ (void)deleteExtraIndexByDataTableName:(NSString*)dataTableName datas:(NSArray*)datas extraIndexNames:(NSArray*)extraIndexNames extraIndexValues:(NSArray*)extraIndexValues dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 删除外部索引记录
 * @param dataTableName 数据表名
 * @param datas 数据列表
 * @param dbDataUtil DBDataUtil实例
 */
+ (void)deleteExtraIndexByDataTableName:(NSString*)dataTableName datas:(NSArray*)datas dbDataUtil:(DBDataUtil*)dbDataUtil;

@end
