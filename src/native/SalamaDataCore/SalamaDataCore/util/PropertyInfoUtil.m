//
//  PropertyInfoUtil.m
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-15.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "PropertyInfoUtil.h"
#import "PropertyInfo.h"

@interface PropertyInfoUtil(PrivateMethod)

+(NSArray*)findAllSuperClass:(Class)objCls;

+(NSArray*) getPropertyInfoArrayNoCache:(Class)dataCls;

+(NSDictionary*) getPropertyInfoMapNoCache:(Class)dataCls;

+(void) getPropertyInfoArrayNotIncludeSuperClass:(Class)dataCls propertyArray:(NSMutableArray*)propertyArray;

+(void) getPropertyInfoMapNotIncludeSuperClass:(Class)dataCls propertyDict:(NSMutableDictionary*)propertyDict;

@end

@implementation PropertyInfoUtil

/*
 key:name of the data class 
 value:property dictionary(key:propertyName value:propertyInfo)
 */
static NSMutableDictionary* _dataPropertyInfoDictDict;

/*
 key:name of the data class 
 value:property array(key:propertyName value:propertyInfo)
 */
static NSMutableDictionary* _dataPropertyInfoArrayDict;

+(NSArray*) getPropertyInfoArray:(Class)dataCls
{
    if(_dataPropertyInfoArrayDict == nil)
    {
        _dataPropertyInfoArrayDict = [[NSMutableDictionary alloc] init];
    }
    
    NSString* dataClsName = NSStringFromClass(dataCls);
    NSArray* propertyInfoArray = [_dataPropertyInfoArrayDict objectForKey:dataClsName];
    
    if(propertyInfoArray == nil)
    {
        propertyInfoArray = [PropertyInfoUtil getPropertyInfoArrayNoCache:dataCls];
        [_dataPropertyInfoArrayDict setObject:propertyInfoArray forKey:dataClsName];
    }

    return propertyInfoArray;
}

//Array of PropertyInfo
+(NSArray*) getPropertyInfoArrayNoCache:(Class)dataCls
{
    NSMutableArray* propertyArray = [[NSMutableArray alloc] init];
    
    NSArray* superClassArray = [PropertyInfoUtil findAllSuperClass:dataCls];
    
    NSInteger superClassCount = superClassArray.count;
    
    for(NSInteger i = superClassCount - 1; i >= 0; i--)
    {
        [PropertyInfoUtil getPropertyInfoArrayNotIncludeSuperClass:[superClassArray objectAtIndex:i] propertyArray:propertyArray];
    }
    
    [PropertyInfoUtil getPropertyInfoArrayNotIncludeSuperClass:dataCls propertyArray:propertyArray];
    
    return propertyArray;
}

+(NSDictionary*)getPropertyInfoMap:(Class)dataCls
{
    if(_dataPropertyInfoDictDict == nil)
    {
        _dataPropertyInfoDictDict = [[NSMutableDictionary alloc] init];
    }
    
    NSString* dataClsName = NSStringFromClass(dataCls);
    NSDictionary* propertyDict = [_dataPropertyInfoDictDict objectForKey:dataClsName];
    
    if(propertyDict == nil)
    {
        propertyDict = [PropertyInfoUtil getPropertyInfoMapNoCache:dataCls];
        [_dataPropertyInfoDictDict setObject:propertyDict forKey:dataClsName];
    }
    
    return propertyDict;
}

//Dictionary of PropertyInfo. Key:propertyName value:propertyInfo
+(NSDictionary*) getPropertyInfoMapNoCache:(Class)dataCls
{
    NSMutableDictionary* propertyDict = [[NSMutableDictionary alloc] init];
    
    NSArray* superClassArray = [PropertyInfoUtil findAllSuperClass:dataCls];
    
    NSInteger superClassCount = superClassArray.count;
    
    if(superClassCount > 0)
    {
        for(NSInteger i = superClassCount - 1; i >= 0; i--)
        {
            [PropertyInfoUtil getPropertyInfoMapNotIncludeSuperClass:[superClassArray objectAtIndex:i] propertyDict:propertyDict];
        }
    }
    
    [PropertyInfoUtil getPropertyInfoMapNotIncludeSuperClass:dataCls propertyDict:propertyDict];
    
    return propertyDict;
}


+(NSArray*)findAllSuperClass:(Class)objCls
{
    NSMutableArray* superClassArray = [[NSMutableArray alloc] init];
    
    Class clsTmp = [objCls superclass];

    while(![NSStringFromClass(clsTmp) isEqualToString:@"NSObject"])
    {
        [superClassArray addObject:clsTmp];
        
        clsTmp = [clsTmp superclass];
    }
    
    return superClassArray;
}

//Array of PropertyInfo
+(void) getPropertyInfoArrayNotIncludeSuperClass:(Class)dataCls propertyArray:(NSMutableArray*)propertyArray
{
    unsigned int propertiesCount;
    objc_property_t* properties = class_copyPropertyList(dataCls, &propertiesCount);
    
    objc_property_t property;
    
    //NSMutableArray* propertyArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < propertiesCount; i++)
    {
        property = properties[i];
        
//        NSString* propName = [NSString stringWithUTF8String:property_getName(property)];
//        NSString* propAttr = [NSString stringWithUTF8String:property_getAttributes(property)];
        PropertyInfo* propInfo = [[PropertyInfo alloc] initWithProperty:property];
        
        if(propInfo != nil)
        {
            [propertyArray addObject:propInfo];
        }
    }
    
    free(properties);
    
    //return propertyArray;
}

//Dictionary of PropertyInfo. Key:propertyName value:propertyInfo
+(void) getPropertyInfoMapNotIncludeSuperClass:(Class)dataCls propertyDict:(NSMutableDictionary*)propertyDict
{
    unsigned int propertiesCount;
    objc_property_t* properties = class_copyPropertyList(dataCls, &propertiesCount);
    
    objc_property_t property;
    
    //NSMutableDictionary* propertyDict = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < propertiesCount; i++)
    {
        property = properties[i];
        
        PropertyInfo* propInfo = [[PropertyInfo alloc] initWithProperty:property];
        
        if(propInfo != nil)
        {
            [propertyDict setObject:propInfo forKey:propInfo.propertyName];
        }
    }
    
    free(properties);
    
    //return propertyDict;
}

@end
