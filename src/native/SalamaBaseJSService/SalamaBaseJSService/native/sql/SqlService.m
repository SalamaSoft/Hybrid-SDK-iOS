//
//  SqlService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SqlService.h"

#import <libxml/parser.h>

@interface SqlService()

- (NSString*)getColTypeMappingKeyOfTable:(NSString*)table colName:(NSString*)colName;

- (void)loadColTypesOfTable:(NSString*)table;

- (void)setColTypeOfTable:(NSString*)table colName:(NSString*)colName  colType:(NSString*)colType;

- (NSString*)getColTypeOfTable:(NSString*)table colName:(NSString*)colName;

@end

@implementation SqlService

- (id)initWithDataService:(SalamaDataService *)dataService
{
    if(self = [super init])
    {
        _colTypeMapping = [[NSMutableDictionary alloc] init];
        _dataService = dataService;
    }
    
    return self;
}


- (int)isTableExists:(NSString *)tableName
{
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];
    
    @try {
        if([dbDataUtil isTableExists:tableName])
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    @finally {
        [dbDataUtil close];
    }
}

- (NSString *)createTable:(TableDesc *)tableDesc
{
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];
    
    @try {
        if(![dbDataUtil isTableExists:tableDesc.tableName])
        {
            [dbDataUtil createTable:tableDesc];
        }
        
        return tableDesc.tableName;
    }
    @finally {
        [dbDataUtil close];
    }
}

- (NSString *)dropTable:(NSString *)tableName
{
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];
    
    @try {
        [dbDataUtil dropTable:tableName];
        
        return tableName;
    }
    @finally {
        [dbDataUtil close];
    }
}

- (NSString *)executeQuery:(NSString *)sql dataNodeName:(NSString *)dataNodeName
{
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];
    
    @try {
        return [dbDataUtil.sqliteUtil findDataListXml:sql dataTypeName:dataNodeName];
    }
    @finally {
        [dbDataUtil close];
    }
}

- (int)executeUpdate:(NSString *)sql
{
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];
    
    @try {
        return [dbDataUtil.sqliteUtil executeUpdate:sql];
    }
    @finally {
        [dbDataUtil close];
    }
}

- (NSString *)insertData:(NSString *)dataTable dataXml:(NSString *)dataXml
{
    //make sql ------------------
    NSMutableString* sqlColNamesPart = [[NSMutableString alloc] init];
    NSMutableString* sqlColValuesPart = [[NSMutableString alloc] init];
    
    [sqlColNamesPart appendString:@"("];
    [sqlColValuesPart appendString:@"("];
    
    xmlDocPtr xmlDoc = NULL;
    xmlNodePtr rootNode = NULL;
    xmlNodePtr nodeTmp = NULL;
    xmlKeepBlanksDefault(0);
    
    NSString* nodeName = nil;
    NSString* nodeValue = nil;
    NSString* colType = nil;
    
    @try {
        xmlDoc = xmlReadDoc(BAD_CAST([dataXml UTF8String]), "InsertDataXml.xml", NULL, XML_PARSE_NONET | XML_PARSE_NODICT | XML_PARSE_NOCDATA);
        
        rootNode = xmlDocGetRootElement(xmlDoc);
        
        nodeTmp = rootNode->children;
        
        int colIndex = 0;
        while(nodeTmp != NULL)
        {
            nodeName = [NSString stringWithUTF8String:(char*)nodeTmp->name];
            nodeValue = [SimpleMetoXML getNodeContent:nodeTmp];
            
            //col name
            if(colIndex != 0)
            {
                [sqlColNamesPart appendString:@","];
                [sqlColValuesPart appendString:@","];
            }
            [sqlColNamesPart appendString:nodeName];

            //col type
            colType = [self getColTypeOfTable:dataTable colName:nodeName];
            if([colType isEqualToString:@"text"])
            {
                [sqlColValuesPart appendFormat:@"'%@'", [SqliteUtil encodeQuoteChar:nodeValue]];
            }
            else
            {
                [sqlColValuesPart appendString:nodeValue];
            }
            
            nodeName = nil;
            nodeTmp = nodeTmp->next;
            colIndex++;
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
    
    [sqlColNamesPart appendString:@")"];
    [sqlColValuesPart appendString:@")"];
    NSString* sql = [NSString stringWithFormat:@"insert into %@ %@ values %@", dataTable, sqlColNamesPart, sqlColValuesPart];
    
    //execute sql ------------------
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];

    @try {
        int success = [dbDataUtil.sqliteUtil executeUpdate:sql];
        if(success)
        {
            return dataXml;
        }
        else
        {
            return nil;
        }
    }
    @finally {
        [dbDataUtil close];
    }
}

- (void)setColTypeOfTable:(NSString *)table colName:(NSString *)colName colType:(NSString *)colType
{
    NSString* colTypeLower = [colType lowercaseString];
    if([colTypeLower isEqualToString:@"text"] || [colTypeLower isEqualToString:@"integer"] || [colTypeLower isEqualToString:@"real"])
    {
        NSString* key = [self getColTypeMappingKeyOfTable:table colName:colName];
        SSLogDebug(@" col:%@ type:%@", key, colTypeLower);
        [_colTypeMapping setObject:colTypeLower forKey:key];
    }
}

- (NSString *)getColTypeOfTable:(NSString *)table colName:(NSString *)colName
{
    NSString* key = [self getColTypeMappingKeyOfTable:table colName:colName];
    
    NSString* colType = [_colTypeMapping objectForKey:key];
    
    if(colType == nil)
    {
        [self loadColTypesOfTable:table];

        return [_colTypeMapping objectForKey:key];
    }
    else
    {
        return colType;
    }
}

- (NSString *)getColTypeMappingKeyOfTable:(NSString *)table colName:(NSString *)colName
{
    return [[[table lowercaseString] stringByAppendingString:@"."] stringByAppendingString:[colName lowercaseString]];
}

- (void)loadColTypesOfTable:(NSString *)table
{
    DBDataUtil* dbDataUtil = [_dataService.dbManager createNewDBDataUtil];
    
    NSString* createTblSql = nil;
    
    @try {
        createTblSql = [dbDataUtil.sqliteUtil executeStringScalar:[NSString stringWithFormat:@"select sql from sqlite_master where lower(tbl_name) = lower('%@')", table]];
    }
    @finally {
        [dbDataUtil close];
    }

    if(createTblSql == nil || createTblSql.length == 0)
    {
        SSLogError(@"Warning: Table %@ does not exists in sqlite DB", table);
        return;
    }
    
    NSRange range0 = [createTblSql rangeOfString:@"("];
    NSRange range1 = [createTblSql rangeOfString:@")" options:NSBackwardsSearch];
    
    NSRange rangeOfColsPart;
    rangeOfColsPart.location = range0.location + 1;
    rangeOfColsPart.length = range1.location - rangeOfColsPart.location - 1;
    NSString* colsPart = [createTblSql substringWithRange:rangeOfColsPart];
    
    NSArray* colPartArray = [colsPart componentsSeparatedByString:@","];
    NSString* colPart = nil;
    NSString* colName = nil;
    NSString* colType = nil;
    NSRange rangeOfSpace;
    for(int i = 0; i < colPartArray.count; i++)
    {
        colPart = [(NSString*)[colPartArray objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        rangeOfSpace = [colPart rangeOfString:@" "];
        if(rangeOfSpace.location != NSNotFound)
        {
            colName = [[colPart substringToIndex:rangeOfSpace.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            colType = [[colPart substringFromIndex:rangeOfSpace.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [self setColTypeOfTable:table colName:colName colType:colType];
        }
    }
    
}

@end
