//
//  SalamaCloudSqlService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalamaCloudSqlService : NSObject

+ (SalamaCloudSqlService*)singleton;

/**
 * 执行查询语句
 * @param sql sql文
 * @return 查询结果(Xml，格式如<List><TestData>...</TestData><TestData>...</TestData>......</List>)
 */
- (NSString*)executeQuery:(NSString*)sql;

/**
 * 执行更新语句(update或delete)
 * @param sql sql文
 * @return 1:成功 0:出错
 */
- (int)executeUpdate:(NSString*)sql;

/**
 * 插入数据
 * @param dataTable 表名
 * @param dataXml 数据XML
 * @param aclRestrictUserRead 指定拥有读权限的用户(多个用户idd逗号分割.该值未指定或空则仅仅数据创建者可以操作.'%'代表任何用户可以操作),
 * @param aclRestrictUserUpdate 指定拥有读权限的用户
 * @param aclRestrictUserDelete 指定拥有读权限的用户
 * @return 实际插入的数据XML。如果为空，则代表操作出错
 */
- (NSString*)insertData:(NSString*)dataTable dataXml:(NSString*)dataXml aclRestrictUserRead:(NSString*)aclRestrictUserRead aclRestrictUserUpdate:(NSString*)aclRestrictUserUpdate aclRestrictUserDelete:(NSString*)aclRestrictUserDelete;

@end
