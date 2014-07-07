//
//  SimpleMetoXML.m
//  WorkHarder
//
//  Created by XingGu Liu on 12-5-1.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "SimpleMetoXML.h"

@interface SimpleMetoXML (PrivateMethod)

+ (void)objectToXml:(NSMutableString*)xml obj:(id)obj nodeName:(NSString*)nodeName;
+ (void)baseObjectToXml:(NSMutableString*)xml obj:(id)obj nodeName:(NSString*)nodeName;
+ (void)dataObjectToXml:(NSMutableString*)xml data:(id)data nodeName:(NSString*)nodeName;

+(id) xmlNodeToObject:(xmlNodePtr)xmlNode type:(Class)type elementType:(Class)elementType;
+(id) xmlNodeToBaseObject:(xmlNodePtr)xmlNode type:(Class)type;

//libxml Version
+(id) xmlNodeToDataObject:(xmlNodePtr)xmlNode type:(Class)type dataPropertyInfoDict:(NSDictionary*)dataPropertyInfoDict;

+(BOOL)isArrayType:(Class)type;

@end

@implementation SimpleMetoXML

static NSString* SIMPLE_METO_TAG_NAME_BEGIN_FORMAT = @"<%@>"; 
static NSString* SIMPLE_METO_TAG_NAME_END_FORMAT = @"</%@>"; 

static NSString* SIMPLE_METO_TAG_NAME_FORMAT_STRING = @"<%@>%@</%@>";

static NSString* SIMPLE_METO_TAG_NAME_FORMAT_LONG = @"<%@>%lld</%@>";

static NSString* SIMPLE_METO_TAG_NAME_FORMAT_DOUBLE = @"<%@>%Lf</%@>";

static NSString* SIMPLE_METO_TAG_NAME_BEGIN_LIST = @"<List>";
static NSString* SIMPLE_METO_TAG_NAME_END_LIST = @"</List>";


+ (NSString *)getNodeContent:(xmlNodePtr)xmlNode
{
    /*
    char* xmlTextTmp = (char*)xmlNodeGetContent(xmlNode);
    int cstrLen = strlen(xmlTextTmp);
    
    char* xmlTextBuff = malloc(cstrLen + 1);
    memcpy(xmlTextBuff, xmlTextTmp, cstrLen);
    xmlTextBuff[cstrLen] = 0;
    
    free(xmlTextTmp);
    
    NSString* strValue = [NSString stringWithUTF8String:xmlTextBuff];
    
    free(xmlTextBuff);
    
    return strValue;
    */

    char* xmlTextTmp = (char*)xmlNodeGetContent(xmlNode);
    
    NSString* strValue = [NSString stringWithUTF8String:xmlTextTmp];
    
    free(xmlTextTmp);
    
    return strValue;
}

+(NSString*) objectToString:(id)obj
{
    if(obj == nil)
    {
        return @"";
    }
    else
    {
        NSMutableString* xml = [[NSMutableString alloc] init];
        
        [SimpleMetoXML objectToXml:xml obj:obj nodeName:nil];
        
        return xml;
    }
}

+(id) stringToObject:(NSString*)xml
{
    return [self stringToObject:xml dataType:NULL];
}

+(id) stringToObject:(NSString*)xml dataType:(Class)dataType
{
    if(xml == nil || xml.length == 0)
    {
        return nil;
    }
    
    xmlDocPtr xmlDoc = NULL;
    xmlNodePtr rootNode = NULL;
    //xmlNodePtr nodeTmp = NULL;
    
    xmlKeepBlanksDefault(0);

    @try {
        xmlDoc = xmlReadDoc(BAD_CAST([xml UTF8String]), "SimpleMetoXml.xml", NULL, XML_PARSE_NONET | XML_PARSE_NODICT | XML_PARSE_NOCDATA);
        
        rootNode = xmlDocGetRootElement(xmlDoc);

        if(rootNode == NULL)
        {
            return nil;
        }
        
        NSString* nodeName = [NSString stringWithUTF8String:(char*)rootNode->name];
        
        if([nodeName isEqualToString:@"List"])
        {
            /*
            NSMutableArray* array = [[NSMutableArray alloc] init];
            
            nodeTmp = rootNode->children;
            
            if(nodeTmp == NULL)
            {
                return array;
            }
            
            if(nodeTmp != NULL)
            {
                Class dataTypeTmp = dataType;
                BOOL isBaseObject = NO;
                
                if(dataType == NULL)
                {
                    NSString* dataNodeName = [NSString stringWithUTF8String:(char*)nodeTmp->name];
                    dataTypeTmp = [BaseTypesMapping getSupportedBaseObjectTypeByDisplayName:dataNodeName];
                    if(dataTypeTmp == NULL)
                    {
                        isBaseObject = NO;
                        dataTypeTmp = NSClassFromString(dataNodeName);
                    }
                    else {
                        isBaseObject = YES;
                    }
                }
                else {
                    isBaseObject = [BaseTypesMapping isSupportedBaseObjectType:dataType];
                }
                
                
                if(isBaseObject)
                {
                    while(nodeTmp != NULL)
                    {
                        id data = [self xmlNodeToBaseObject:nodeTmp type:dataTypeTmp];
                        
                        [array addObject:data];
                        
                        nodeTmp = nodeTmp->next;
                    }
                }
                else
                {
                    NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:dataTypeTmp];
                    while(nodeTmp != NULL)
                    {
                        id data = [self xmlNodeToDataObject:nodeTmp type:dataTypeTmp dataPropertyInfoDict:propertyInfoDict];
                        
                        [array addObject:data];
                        
                        nodeTmp = nodeTmp->next;
                    }
                }
            }
            
            rootNode = nil;
            nodeName = nil;
            
            return array;
            */
            
            return [SimpleMetoXML xmlNodeToObject:rootNode type:[NSArray class] elementType:NULL];
        }
        else 
        {
            /*
            Class dataTypeTmp = dataType;
            BOOL isBaseObject = NO;
            
            if(dataType == NULL)
            {
                dataTypeTmp = [BaseTypesMapping getSupportedBaseObjectTypeByDisplayName:nodeName];
                if(dataTypeTmp == NULL)
                {
                    isBaseObject = NO;
                    dataTypeTmp = NSClassFromString(nodeName);
                }
                else {
                    isBaseObject = YES;
                }
            }
            else {
                isBaseObject = [BaseTypesMapping isSupportedBaseObjectType:dataType];
            }

            if(isBaseObject)
            {
                return [self xmlNodeToBaseObject:rootNode type:dataTypeTmp];
            }
            else
            {
                NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:dataTypeTmp];
                return [self xmlNodeToDataObject:rootNode type:dataTypeTmp dataPropertyInfoDict:propertyInfoDict];
            }
            */
            Class dataTypeTmp = dataType;
            
            if(dataType == NULL)
            {
                dataTypeTmp = [BaseTypesMapping getSupportedBaseObjectTypeByDisplayName:nodeName];
                if(dataTypeTmp == NULL)
                {
                    dataTypeTmp = NSClassFromString(nodeName);
                }
            }
            return [SimpleMetoXML xmlNodeToObject:rootNode type:dataTypeTmp elementType:NULL];
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        //xmlFreeNodeList(rootNode);
        xmlFreeDoc(xmlDoc);
        //xmlCleanupParser();
        //xmlCleanupMemory();
    }
    
}

/***** Private Methods *****/

#pragma mark - serialize

/** 
 This version is only support very simple data object, such as the data which only has primitive type properties, and the list of such data object.
**/ 
/*
 + (void)objectToXml:(NSMutableString *)xml obj:(id)obj
 {
 if([obj isKindOfClass:[NSArray class]])
 {
 [xml appendString:SIMPLE_METO_TAG_NAME_BEGIN_LIST];
 
 if([(NSArray*)obj count] > 0)
 {
 NSString* displayName = [BaseTypesMapping getDisplayNameBySupportedBaseObjectType:[[(NSArray*)obj objectAtIndex:0] class]];
 if(displayName != nil)
 {
 for(id data in (NSArray*)obj)
 {
 [SimpleMetoXML baseObjectToXml:xml obj:data nodeName:displayName];
 }
 }
 else
 {
 displayName = NSStringFromClass([[(NSArray*)obj objectAtIndex:0] class]);
 for(id data in (NSArray*)obj)
 {
 [SimpleMetoXML dataObjectToXml:xml data:data nodeName:displayName];
 }
 }
 }
 
 [xml appendString:SIMPLE_METO_TAG_NAME_END_LIST];
 }
 else
 {
 NSString* displayName = [BaseTypesMapping getDisplayNameBySupportedBaseObjectType:[obj class]];
 if(displayName != nil)
 {
 [SimpleMetoXML baseObjectToXml:xml obj:obj nodeName:displayName];
 }
 else
 {
 displayName = NSStringFromClass([obj class]);
 [SimpleMetoXML dataObjectToXml:xml data:obj nodeName:displayName];
 }
 }
 }
 */


/**
 This version support most of cases. But is uses recursive invoking, so this class is called SimpleMetoXml.
 **/
+ (void)objectToXml:(NSMutableString *)xml obj:(id)obj nodeName:(NSString*)nodeName
{
    if(obj == nil)
    {
        return;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        if(nodeName == nil)
        {
            [xml appendString:SIMPLE_METO_TAG_NAME_BEGIN_LIST];
        }
        else 
        {
            [xml appendFormat:SIMPLE_METO_TAG_NAME_BEGIN_FORMAT, nodeName];
        }
        
        if([(NSArray*)obj count] > 0)
        {
            NSString* displayName = [BaseTypesMapping getDisplayNameBySupportedBaseObjectType:[[(NSArray*)obj objectAtIndex:0] class]];
            if(displayName != nil)
            {
                for(id data in (NSArray*)obj)
                {
                    [SimpleMetoXML baseObjectToXml:xml obj:data nodeName:displayName];
                }
            }
            else
            {
                displayName = NSStringFromClass([[(NSArray*)obj objectAtIndex:0] class]);
                for(id data in (NSArray*)obj)
                {
                    [SimpleMetoXML dataObjectToXml:xml data:data nodeName:displayName];
                }
            }
        }
        
        if(nodeName == nil)
        {
            [xml appendString:SIMPLE_METO_TAG_NAME_END_LIST];
        }
        else 
        {
            [xml appendFormat:SIMPLE_METO_TAG_NAME_END_FORMAT, nodeName];
        }
    }
    else
    {
        NSString* displayName = [BaseTypesMapping getDisplayNameBySupportedBaseObjectType:[obj class]];
        if(displayName != nil)
        {
            if(nodeName == nil)
            {
                [SimpleMetoXML baseObjectToXml:xml obj:obj nodeName:displayName];
            }
            else 
            {
                [SimpleMetoXML baseObjectToXml:xml obj:obj nodeName:nodeName];
            }
        }
        else
        {
            if(nodeName == nil)
            {
                displayName = NSStringFromClass([obj class]);
                [SimpleMetoXML dataObjectToXml:xml data:obj nodeName:displayName];
            }
            else
            {
                [SimpleMetoXML dataObjectToXml:xml data:obj nodeName:nodeName];
            }
        }
    }
}

+(void) baseObjectToXml:(NSMutableString*)xml obj:(id)obj nodeName:(NSString*)nodeName;
{
    //supported base object type
    if(obj == nil)
    {
        [xml appendFormat:SIMPLE_METO_TAG_NAME_FORMAT_STRING, nodeName, @"", nodeName];
    }
    else 
    {
        NSString* value = [BaseTypesMapping getStringBySupportedBaseObject:obj];
        
        NSString* encodedValue = [XmlContentEncoder stringByEncodeXmlSpecialChars:value];
        
        [xml appendFormat:SIMPLE_METO_TAG_NAME_FORMAT_STRING, nodeName, encodedValue, nodeName];
        
        value = nil;
        encodedValue = nil;
    }
}

+(void) dataObjectToXml:(NSMutableString*)xml data:(id)data nodeName:(NSString*)nodeName;
{
    Class dataCls = [data class];
    [xml appendFormat:SIMPLE_METO_TAG_NAME_BEGIN_FORMAT, nodeName];
    
    NSArray* propertyInfoArray = [PropertyInfoUtil getPropertyInfoArray:dataCls];

    for(PropertyInfo* propertyInfo in propertyInfoArray)
    {
        if(propertyInfo.propertyType == PropertyType_Other)
        {
            [SimpleMetoXML objectToXml:xml obj:[data valueForKey:propertyInfo.propertyName] nodeName:propertyInfo.propertyName];
        }
        else
        {
            NSString* propStrVal = [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo];
            
            if(propStrVal == nil)
            {
                [xml appendFormat:SIMPLE_METO_TAG_NAME_FORMAT_STRING, propertyInfo.propertyName, @"", propertyInfo.propertyName];
            }
            else 
            {
                NSString* encodedValue = [XmlContentEncoder stringByEncodeXmlSpecialChars:propStrVal];
                
                [xml appendFormat:SIMPLE_METO_TAG_NAME_FORMAT_STRING, propertyInfo.propertyName, encodedValue, propertyInfo.propertyName];
                
                encodedValue = nil;
            }
        }
    }
    
    [xml appendFormat:SIMPLE_METO_TAG_NAME_END_FORMAT, nodeName];
}

#pragma mark - deserialize

+(id) xmlNodeToObject:(xmlNodePtr)xmlNode type:(Class)type elementType:(Class)elementType
{
    if([SimpleMetoXML isArrayType:type])
    {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        xmlNodePtr nodeTmp = NULL;
        NSString* dataNodeName = nil;
        
        nodeTmp = xmlNode->children;
        
        if(nodeTmp == NULL)
        {
            return array;
        }
        
        if(nodeTmp != NULL)
        {
            Class dataTypeTmp = elementType;
            BOOL isBaseObject = NO;
            
            if(dataTypeTmp == NULL)
            {
                dataNodeName = [NSString stringWithUTF8String:(char*)nodeTmp->name];
                dataTypeTmp = [BaseTypesMapping getSupportedBaseObjectTypeByDisplayName:dataNodeName];
                if(dataTypeTmp == NULL)
                {
                    isBaseObject = NO;
                    dataTypeTmp = NSClassFromString(dataNodeName);
                }
                else {
                    isBaseObject = YES;
                }
            }
            else {
                isBaseObject = [BaseTypesMapping isSupportedBaseObjectType:dataTypeTmp];
            }
            
            
            if(isBaseObject)
            {
                while(nodeTmp != NULL)
                {
                    id data = [self xmlNodeToBaseObject:nodeTmp type:dataTypeTmp];
                    
                    [array addObject:data];
                    
                    nodeTmp = nodeTmp->next;
                }
            }
            else
            {
                NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:dataTypeTmp];
                while(nodeTmp != NULL)
                {
                    id data = [self xmlNodeToDataObject:nodeTmp type:dataTypeTmp dataPropertyInfoDict:propertyInfoDict];
                    
                    [array addObject:data];
                    
                    nodeTmp = nodeTmp->next;
                }
            }
        }
        
        return array;
    }
    else 
    {
        NSString* nodeName = [NSString stringWithUTF8String:(char*)xmlNode->name];
        Class dataTypeTmp = type;
        BOOL isBaseObject = NO;
        
        if(dataTypeTmp == NULL)
        {
            dataTypeTmp = [BaseTypesMapping getSupportedBaseObjectTypeByDisplayName:nodeName];
            if(dataTypeTmp == NULL)
            {
                isBaseObject = NO;
                dataTypeTmp = NSClassFromString(nodeName);
            }
            else {
                isBaseObject = YES;
            }
        }
        else {
            isBaseObject = [BaseTypesMapping isSupportedBaseObjectType:dataTypeTmp];
        }
        
        if(isBaseObject)
        {
            return [self xmlNodeToBaseObject:xmlNode type:dataTypeTmp];
        }
        else
        {
            NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:dataTypeTmp];
            return [self xmlNodeToDataObject:xmlNode type:dataTypeTmp dataPropertyInfoDict:propertyInfoDict];
        }
    }
}

+(id) xmlNodeToBaseObject:(xmlNodePtr)xmlNode type:(Class)type;
{
    NSString* stringValue = [SimpleMetoXML getNodeContent:xmlNode];

    return [BaseTypesMapping getSupportedBaseObjectByString:stringValue type:type];
}

+(id) xmlNodeToDataObject:(xmlNodePtr)xmlNode type:(Class)type dataPropertyInfoDict:(NSDictionary*)dataPropertyInfoDict;
{
    xmlNodePtr xmlNodeTmp = xmlNode->children;
    NSString* nodeName;
    NSString* nodeText;
    
    PropertyInfo* propInfo;
    
    id data = [[type alloc] init];
    id value = nil;
    Class valueType = NULL;
    
    while(xmlNodeTmp != NULL)
    {
        nodeName = [NSString stringWithUTF8String:(char*)xmlNodeTmp->name];
                
        propInfo = [dataPropertyInfoDict objectForKey:nodeName];
        
        if(propInfo != nil)
        {
            if(propInfo.propertyType == PropertyType_Other)
            {
                //Data Class Type
                valueType = NSClassFromString(propInfo.propertyClassName);
                value = [SimpleMetoXML xmlNodeToObject:xmlNodeTmp type:valueType elementType:NULL];
                [data setValue:value forKey:propInfo.propertyName];
            }
            else
            {
                //base type
                nodeText = [SimpleMetoXML getNodeContent:xmlNodeTmp];
                
                [BaseTypesMapping setPropertyValueWithStringValue:nodeText data:data propertyInfo:propInfo];
                
                nodeText = nil;
            }
        }
        
        nodeName = nil;
        
        xmlNodeTmp = xmlNodeTmp->next;
    }
    
    return data;
}

+ (BOOL)isArrayType:(Class)type
{
    if(type == [NSArray class] || [type isSubclassOfClass:[NSArray class]])
    {
        return YES;
    }
    else 
    {
        return NO;
    }
}

@end
