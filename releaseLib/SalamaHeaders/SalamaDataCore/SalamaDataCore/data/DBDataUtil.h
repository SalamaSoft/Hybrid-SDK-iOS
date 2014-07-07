//
//  DBDataUtil.h
//  
//
//  Created by XingGu Liu on 12-5-17.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataTableSetting.h"
#import "SqliteUtil.h"
#import "TableDesc.h"

@interface DBDataUtil : NSObject
{
    @protected
    SqliteUtil* _sqliteUtil;

    //Key:tableName value:DataTableSetting
    NSMutableDictionary* _dataTableSettingDict;

    //Key:tableName value:NSSet(ColumnNames of primary key)
    NSMutableDictionary* _primaryKeySetDict;
}

/**
 * 取得SqliteUtil实例
 * @return SqliteUtil实例
 */
-(SqliteUtil*)sqliteUtil;

-(id)init:(SqliteUtil*)sqliteUtil;

/**
 * 关闭数据库连接
 */
-(void)close;

/**
 * 取得主键Set
 */
-(NSSet*) getPrimaryKeySet:(NSString*)tableName;

/**
 * 获取表定义
 * @param tableName 表名
 * @return 表定义
 */
-(DataTableSetting*) getDataTableSetting:(NSString*)tableName;

/**
 * 获取所有表定义
 * @return 表定义列表
 */
-(NSArray*) getAllDataTableSetting;


/**
 * 表是否存在
 * @param tableName 表名
 * @return true:存在 false:不存在
 */
-(bool)isTableExists:(NSString*)tableName;

/**
 * 删除表
 * @param tableName 表名
 */
-(void)dropTable:(NSString*)tableName;

/**
 * 创建表
 * @param tableCls 表对应的data类型
 * @param primaryKeys 主键信息。格式为逗号分隔多个主键。
 */
-(void)createTable:(Class)tableCls primaryKeys:(NSString*)primaryKeys;

/**
 * 创建表
 * @param tableDesc 表结构描述
 */
-(void)createTable:(TableDesc*)tableDesc;

/**
 * 插入记录
 * @param tableName 表名
 * @param data 数据实例
 * @return 1:正常 0:出错
 */
-(int)insertData:(NSString*)tableName data:(id)data;

/**
 * 插入数据
 * @param tableName 表名
 * @param dataCls 对应的数据类型
 * @param dataXml 数据的Xml内容
 * @return 1:正常 0:出错
 */
-(int)insertData:(NSString*)tableName dataXml:(NSString*)dataXml;
//-(void)insertData:(NSString*)tableName dataXml:(NSString*)dataXml dataType:(Class)dataType;

/**
 * 根据主键更新记录
 * @param tableName 表名
 * @param data 数据实例
 * @return 1:正常 0:出错
 */
-(int)updateDataByPK:(NSString*)tableName data:(id)data;

/**
 * 根据主键更新记录
 * @param tableName 表名
 * @param dataXml 数据Xml内容
 * @return 1:正常 0:出错
 */
-(int)updateDataByPK:(NSString*)tableName dataXml:(NSString*)dataXml;
//-(void)updateData:(NSString*)tableName dataXml:(NSString*)dataXml dataType:(Class)dataType;

/**
 * 插入或更新记录(记录已存在时更新)
 * @param tableName 表名
 * @param data 数据实例
 * @return 1:正常 0:出错
 */
-(int)insertOrUpdateDataByPK:(NSString*)tableName data:(id)data;

/**
 * 根据主键删除数据
 * @param tableName 表名
 * @param data 数据实例
 * @return 1:正常 0:出错
 */
-(int)deleteDataByPK:(NSString*)tableName data:(id)data;

/**
 * 根据主键删除记录
 * @param tableName 表名
 * @param dataXml 数据Xml内容
 * @return 1:正常 0:出错
 */
-(int)deleteDataByPK:(NSString*)tableName dataXml:(NSString*)dataXml;
//-(void)deleteData:(NSString*)tableName dataXml:(NSString*)dataXml dataType:(Class)dataType;

/**
 * 删除所有记录
 * @param tableName 表名
 * @return 1:正常 0:出错
 */
-(int)deleteAllData:(NSString*)tableName;

/**
 * 根据主键查询
 * @param tableName 表名
 * @param data 数据实例(只需包含主键信息)
 * @return 查询结果数据实例
 */
-(id)findDataByPK:(NSString*)tableName data:(id)data;

/**
 * 根据主键查询
 * @param tableName 表名
 * @param dataXml 数据Xml内容
 * @return 查询结果数据实例
 */
-(id)findDataByPK:(NSString*)tableName dataXml:(NSString*)dataXml;

/**
 * 根据主键查询数据
 * @param tableName 表名
 * @param data 数据实例
 * @return 数据Xml内容
 */
-(NSString*)findDataXmlByPK:(NSString*)tableName data:(id)data;

/**
 * 根据主键查询
 * @param tableName 表名
 * @param dataXml 数据Xml内容(只需包含主键信息)
 * @return 数据Xml内容
 */
-(NSString*)findDataXmlByPK:(NSString*)tableName dataXml:(NSString*)dataXml;


/**
 * 查询所有数据
 * @param tableName 表名
 * @return 数据列表
 */
-(NSArray*) findAllData:(NSString*)tableName;

/**
 * 查询所有数据
 * @param tableName 表名
 * @return 数据列表Xml内容
 */
-(NSString*) findAllDataXml:(NSString*)tableName;

/**
 * 查询更新时间晚于指定时间的数据
 * @param tableName 表名
 * @param updateTime 指定的时间
 * @return 数据列表
 */
/* Deprecated
-(NSArray*) findDataAfterUpdateTime:(NSString*)tableName updateTime:(long long)updateTime;
*/

/**
 * Deprecated
 * 查询更新时间晚于指定时间的数据
 * @param tableName 表名
 * @param updateTime 指定的时间
 * @return 数据列表Xml内容
 */
/* Deprecated
-(NSString*) findDataXmlAfterUpdateTime:(NSString*)tableName updateTime:(long long)updateTime;
*/

/**
 查询数据
 * @param sql SQL文
 * @param dataType 数据类型
 */
-(NSArray*) findData:(NSString*)sql dataType:(Class)dataType;

/**
 查询数据
 * @param sql SQL文
 * @param dataTypeName 数据类型名
 */
-(NSString*) findDataXml:(NSString*)sql dataTypeName:(NSString*)dataTypeName;


@end
