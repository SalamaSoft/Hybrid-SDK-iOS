//
//  TableDesc.h
//
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColDesc : NSObject

/**
 * 列名。因框架中提供Xml<->Data反射工具，建议大小写敏感，例如"dataId","userName"，这样的典型的data属性名的形式。
 * 注意，如果在ios中定义Data类用于反射，则字段名需须避开关键字，诸如,"id","newXXX"。
 */
@property(nonatomic, retain) NSString* colName;

/**
 * 鉴于SQLITE中实际存在3种列类型：TEXT,INTEGER,REAL。
 * 所以，此处colType仅支持:
 * "text"(不区分大小写):对应TEXT类型。
 * "int","integer"(不区分大小写):对应INTEGER类型
 * "real"(不区分大小写):对应REAL类型
 */
@property(nonatomic, retain) NSString* colType;

- (id)initWithColName:(NSString*)name colType:(NSString*)type;

@end

@interface TableDesc : NSObject

/**
 * 表名。因框架中提供Xml<->Data类的反射工具，建议类似"UserData","CompanyData"，这样的Data类名的形式。
 */
@property(nonatomic, retain) NSString* tableName;

/**
 * 主键描述，格式:逗号分隔的列名。
 */
@property(nonatomic, retain) NSString* primaryKeys;

/**
 * 字段描述，格式:NSArray<ColDesc>。
 */
@property(nonatomic, retain) NSArray* colDescList;

@end
