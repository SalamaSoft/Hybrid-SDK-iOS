//
//  LocalStorageService.h
//  SalamaDataService
//
//  Created by Liu XingGu on 12-9-29.
//
//

#import <Foundation/Foundation.h>

#import "DBDataUtil.h"

@interface LocalStorageService : NSObject

/**
 * 保存数据
 * @param dataTableName 数据表名
 * @param datas 数据列表
 * @param extraIndexNames 外部索引字段名(逗号分隔)
 * @param extraIndexValues 外部索引值(逗号分隔)
 * @param dbDataUtil DBDataUtil实例
 */
- (void)storeDataToTable:(NSString*)tableName datas:(NSArray*)datas extraIndexNames:(NSArray*)extraIndexNames extraIndexValues:(NSArray*)extraIndexValues dbDataUtil:(DBDataUtil*)dbDataUtil;

/**
 * 删除数据
 * @param dataTableName 数据表名
 * @param datas 数据列表
 * @param dbDataUtil DBDataUtil实例
 */
- (void)removeDataAndExtraIndexForTable:(NSString*)tableName datas:(NSArray*)datas dbDataUtil:(DBDataUtil*)dbDataUtil;


@end
