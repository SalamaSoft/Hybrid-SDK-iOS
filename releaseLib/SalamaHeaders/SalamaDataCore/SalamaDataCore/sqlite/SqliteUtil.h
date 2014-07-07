//
//  SqliteUtil.h
//  WorkHarder
//
//  Created by XingGu Liu on 12-5-6.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <objc/runtime.h>

#import "SimpleMetoXML.h"
#import "PropertyInfo.h"
#import "PropertyInfoUtil.h"
#import "XmlContentEncoder.h"
#import "SSLog.h"

@interface SqliteUtil : NSObject
{
    @private
    char* _errorMsg;
    NSString* _dbFilePath;
    sqlite3* _db;
    
    //NSLock* _sqliteLock;
}

/**
 * 编码用于SQL文中的值
 * <BR>仅将 ' 转换为 ''
 * @param strValue 字符串
 * @return 编码后的字符串
 */
+(NSString*)encodeQuoteChar:(NSString*)strValue;

/**
 * 根据属性类型取得SQLite数据类型
 * @param propertyType 属性类型
 * @return Sqlite数据类型
 */
+(int)getSQLiteColumnTypeByPropertyType:(PropertyType)propertyType;

/**
 * 创建SqliteUtil
 * @param dbFilePath 数据库文件路径
 * @return SqliteUtil
 */
+(SqliteUtil*)sqliteUtilWithDBFilePath:(NSString*)dbFilePath;

/**
 * 初始化
 * @param dbFilePath 数据库文件路径
 * @return SqliteUtil
 */
-(id) init:(NSString*) dbFilePath;

/**
 * 打开数据库连接
 */
-(void) open;

/**
 * 关闭数据库连接
 */
-(void) close;

/**
 * 取得Sqlite数据库连接对象
 * @return Sqlite数据库连接对象
 */
-(sqlite3*) db;

//-(NSSet*) getPrimaryKeySet:(Class)dataType;

/**
 * 取得数据库文件路径
 */
-(NSString*) dbFilePath;

/**
 * 查询整型字段
 * @param sql SQL文
 * @return 第1条记录的第1个字段
 */
-(int) executeIntScalar:(NSString*)sql;

/**
 * 查询长整型字段
 * @param sql SQL文
 * @return 第1条记录的第1个字段
 */
-(long long) executeLongScalar:(NSString*)sql;

/**
 * 查询双精度浮点字段
 * @param sql SQL文
 * @return 第1条记录的第1个字段
 */
-(double) executeDoubleScalar:(NSString*)sql;

/**
 * 查询字符串字段
 * @param sql SQL文
 * @return 第1条记录的第1个字段
 */
-(NSString*) executeStringScalar:(NSString*)sql;

/**
 * 查询数据
 * @param sql SQL文
 * @param dataType 数据类型
 * @return 数据列表
 */
-(NSArray*) findDataList:(NSString*)sql dataType:(Class)dataType;

/**
 * 查询数据
 * @param sql SQL文
 * @param dataType 数据类型
 * @return 单条数据
 */
-(id) findData:(NSString*)sql dataType:(Class)dataType;

/**
 * 查询数据
 * @param sql SQL文
 * @param dataType 数据类型
 * @return 数据列表Xml内容
 */
-(NSString*) findDataListXml:(NSString*)sql dataTypeName:(NSString*)dataTypeName;

/**
 * 查询数据
 * @param sql SQL文
 * @param dataType 数据类型
 * @return 单条数据Xml内容
 */
-(NSString*) findDataXml:(NSString*)sql dataTypeName:(NSString*)dataTypeName;

/**
 * 执行更新语句
 * @param sql SQL文
 * @return 1:正常 0:出错
 */
-(int) executeUpdate:(NSString*)sql;

@end
