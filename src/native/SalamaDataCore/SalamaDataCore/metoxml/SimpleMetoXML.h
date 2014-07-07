//
//  SimpleMetoXML.h
//  SalamaNativeUtils
//
//  Only support:
//  1. NSString,NSDecimalNumber,NSDate,NSData
//  2. Data object whose properties are these types:
//     Types supported in BaseTypesMapping: char,bool,BOOL,short,int,long,long long,
//     float,double,String,Decimal,Date.
//  3. NSArray of the object type descripted in 1. or 2.
////
//  Created by XingGu Liu on 12-5-1.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import <libxml/parser.h>

#import "XmlContentEncoder.h"
#import "PropertyInfoUtil.h"
#import "BaseTypesMapping.h"

@interface SimpleMetoXML : NSObject

/**
 * 取得Xml节点的内容
 * @return 内容
 */
+ (NSString*)getNodeContent:(xmlNodePtr)xmlNode;

/**
 * Object转换至Xml
 * @return Xml
 */
+(NSString*) objectToString:(id)obj;

/**
 * Xml转换至Object。Object类型根据根节点名。
 * @return Object
 */
+(id) stringToObject:(NSString*)xml;

/**
 * Xml转换至Object。
 * @param dataType 根节点
 * @return Object
 */
+(id) stringToObject:(NSString*)xml dataType:(Class)dataType;

@end
