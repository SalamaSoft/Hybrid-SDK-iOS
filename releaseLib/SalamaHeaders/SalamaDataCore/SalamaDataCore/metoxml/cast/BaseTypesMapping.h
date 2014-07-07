//
//  BaseTypesMapping.h
//  MoreGifts
//
//  MetoXml is designed for communicating between multiple platform(java,C#,objective-c),
//  so unsigned number is not supported.
//
//  Created by XingGu Liu on 12-5-15.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PropertyInfo.h"
#import "PropertyInfoUtil.h"
#import "BaseTypeConverter.h"

@interface BaseTypesMapping : NSObject

+(BOOL)isSupportedBaseType:(PropertyType)propertyType;

+(BOOL)isSupportedBaseTypeByDisplayName:(NSString*)propertyTypeDisplayName;
+(NSString*)getSupportedBaseTypeDisplayName:(PropertyType)propertyType;

+(BOOL)isSupportedBaseObjectType:(Class)type;

+(NSString*)getDisplayNameBySupportedBaseObjectType:(Class)type;
+(Class)getSupportedBaseObjectTypeByDisplayName:(NSString*)displayName;

+(NSString*)getStringBySupportedBaseObject:(id)obj;
+(id)getSupportedBaseObjectByString:(NSString*)stringValue type:(Class)type;


+(void)setPropertyValueWithStringValue:(NSString*)strValue data:(id)data propertyInfo:(PropertyInfo*)propertyInfo;
+(NSString*)getPropertyStringValueWithData:(id)data propertyInfo:(PropertyInfo*)propertyInfo;

@end
