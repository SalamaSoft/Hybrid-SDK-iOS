//
//  SqlService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableDesc.h"
#import "SalamaDataService.h"

@interface SqlService : NSObject
{
    @private
    NSMutableDictionary* _colTypeMapping;
    SalamaDataService* _dataService;
}

- (id)initWithDataService:(SalamaDataService*) dataService;

/**
 * 判断表是否已经存在
 * @param tableName 表名
 * @return 0:不存在 1:存在
 */
- (int)isTableExists:(NSString *)tableName;

/**
 * 建表(如果表已经存在，则不做任何事)
 * @param tableDesc 表结构描述
 * @return 表名
 */
- (NSString*)createTable:(TableDesc*)tableDesc;

/**
 * 删表
 * @param tableName 表名
 * @return 表名
 */
- (NSString*)dropTable:(NSString*)tableName;

/**
 * 执行查询语句
 * @param sql sql文
 * @return 查询结果(XML格式。例:<List><TestData>...</TestData><TestData>...</TestData>......</List>)
 */
- (NSString*)executeQuery:(NSString*)sql dataNodeName:(NSString*)dataNodeName;

/**
 * 执行更新语句(update或delete)
 * @param sql sql文
 * @return 1:成功 0:失败
 */
- (int)executeUpdate:(NSString*)sql;

/**
 * 插入数据
 * @param dataTable 表名
 * @param dataXml 数据XML
 * @return dataXml 数据XML。失败的场合，返回nil。
 */
- (NSString*)insertData:(NSString*)dataTable dataXml:(NSString*)dataXml;


@end
