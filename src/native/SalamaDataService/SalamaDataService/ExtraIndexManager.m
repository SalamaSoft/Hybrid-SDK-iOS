//
//  ExtraIndexManager.m
//  SalamaDataService
//
//  Created by Liu XingGu on 12-9-29.
//
//

#import "ExtraIndexManager.h"

#import "DBDataSqlConsts.h"

#define PREFIX_SETTING_TABLE_NAME @"ExtraIndex"

@interface ExtraIndexManager(PrivateMethod)

@end

@implementation ExtraIndexManager

+ (NSString*)getExtraIndexTableNameByDataTableName:(NSString*)dataTableName
{
    return [PREFIX_SETTING_TABLE_NAME stringByAppendingString:dataTableName];
}

+ (void)createExtraIndexTableWithDataTableName:(NSString *)dataTableName dataPrimaryKeys:(NSString *)dataPrimaryKeys extraIndexes:(NSString *)extraIndexes dataClass:(Class)dataClass dbDataUtil:(DBDataUtil *)dbDataUtil
{
    NSMutableString* sql = [[NSMutableString alloc] init];
    
    NSString* indexTableName = [ExtraIndexManager getExtraIndexTableNameByDataTableName:dataTableName];
    
    [sql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_TABLE_NAME, indexTableName];
    
    int i = 0;

    //index coloumn
    NSArray* indexNameArray = [extraIndexes componentsSeparatedByString:@","];
    for(i = 0; i < indexNameArray.count; i++)
    {
        [sql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_TEXT, [indexNameArray objectAtIndex:i]];
    }
    
    //data pk column
    NSArray* pkNameArray = [dataPrimaryKeys componentsSeparatedByString:@","];
    
    NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:dataClass];
    int sqliteColumnType;

    BOOL isPK;
    int k;
    
    for (PropertyInfo* propertyInfo in propertyArray) {
        isPK = NO;
        for(k = 0; k < pkNameArray.count; k++)
        {
            if([[pkNameArray objectAtIndex:k] isEqualToString:propertyInfo.propertyName])
            {
                isPK = YES;
                break;
            }
        }
        
        if(!isPK)
        {
            continue;
        }
        
        sqliteColumnType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
        
        if(sqliteColumnType == SQLITE_TEXT)
        {
            [sql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_TEXT, propertyInfo.propertyName];
        }
        else if(sqliteColumnType == SQLITE_INTEGER)
        {
            [sql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_INTEGER, propertyInfo.propertyName];
        }
        else if(sqliteColumnType == SQLITE_FLOAT)
        {
            [sql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_REAL, propertyInfo.propertyName];
        }
    }
    
    //primary key for this table
    NSMutableString* pkOfThisTable = [[NSMutableString alloc] init];
    [pkOfThisTable appendString:extraIndexes];
    
    if(![extraIndexes hasSuffix:@","]
       && ![dataPrimaryKeys hasPrefix:@","])
    {
        [pkOfThisTable appendString:@","];
    }
    [pkOfThisTable appendString:dataPrimaryKeys];
    
    [sql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_PRIMARY_KEY, pkOfThisTable];
    
    
    //end of create table
    [sql appendString:DB_SQL_FORMAT_CREATE_TABLE_END];
    
    //Execute the sql
    [dbDataUtil.sqliteUtil executeUpdate:sql];
    
}

+ (void)dropExtraIndexTableByDataTableName:(NSString *)dataTableName dbDataUtil:(DBDataUtil *)dbDataUtil
{
    [dbDataUtil dropTable:[ExtraIndexManager getExtraIndexTableNameByDataTableName:dataTableName]];
}

+ (void)insertExtraIndexWithDataTableName:(NSString *)dataTableName datas:(NSArray *)datas extraIndexNames:(NSArray *)extraIndexNames extraIndexValues:(NSArray *)extraIndexValues dbDataUtil:(DBDataUtil *)dbDataUtil
{
    if(datas == nil || datas.count == 0)
    {
        return;
    }
    
    int i;
    
    //create sql format -------------------------------------------------
    NSMutableString* sqlFormat = [[NSMutableString alloc] init];

    //beginning of sql
    [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_TABLE, [ExtraIndexManager getExtraIndexTableNameByDataTableName:dataTableName]];
    
    //columns of extra indexes
    [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN, [extraIndexNames objectAtIndex:0]];
    for(i = 1; i < extraIndexNames.count; i++)
    {
        [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN, [extraIndexNames objectAtIndex:i]];
    }
    
    //columns of data primary keys
    DataTableSetting* dataTableSetting = [dbDataUtil getDataTableSetting:dataTableName];
    NSArray* dataPkArray = [dataTableSetting.primaryKeys componentsSeparatedByString:@","];
    for(i = 0; i < dataPkArray.count; i++)
    {
        [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN, [dataPkArray objectAtIndex:i]];
    }
    
    // end of setting columns ----
    [sqlFormat appendString:DB_SQL_FORMAT_INSERT_SET_COLUMN_END];
    
    //value of extra indexes
    [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_STRING, [extraIndexValues objectAtIndex:0]];
    for(i = 1; i < extraIndexValues.count; i++)
    {
        [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_STRING, [extraIndexValues objectAtIndex:i]];
    }

    //value format of data primary keys
    //[sqlFormat appendString:@"%@"];
    //end of sql format
    //[sqlFormat appendString:DB_SQL_FORMAT_INSERT_END];
        
    
    // set values of primary key ------------------------------------------------------------------
    //data pk column
    NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:[[datas objectAtIndex:0] class]];
    int sqliteType;
    PropertyInfo* propertyInfo = nil;

    NSMutableArray* propertyInfoArrayOfPKs = [[NSMutableArray alloc] init];
    for(i = 0; i < dataPkArray.count; i++)
    {
        propertyInfo = [propertyInfoDict objectForKey:[dataPkArray objectAtIndex:i]];
        
        [propertyInfoArrayOfPKs addObject:propertyInfo];
    }
    
    //sql
    int sqlPrefixLength = sqlFormat.length;
    NSRange rangeOfSqlDataPKPart;
    rangeOfSqlDataPKPart.location = sqlFormat.length;
    
    id oneDataTmp = nil;

    for(int k = 0; k < datas.count; k++)
    {
        rangeOfSqlDataPKPart.length = sqlFormat.length - sqlPrefixLength;
        if(rangeOfSqlDataPKPart.length > 0)
        {
            [sqlFormat deleteCharactersInRange:rangeOfSqlDataPKPart];
        }

        oneDataTmp = [datas objectAtIndex:k];
        
        //handle one data row ----------------------
        for(i = 0; i < propertyInfoArrayOfPKs.count; i++)
        {
            propertyInfo = [propertyInfoArrayOfPKs objectAtIndex:i];
            
            sqliteType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            if(sqliteType == SQLITE_TEXT)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_STRING, [SqliteUtil encodeQuoteChar:[oneDataTmp valueForKey:propertyInfo.propertyName]]];
            }
            else if(sqliteType == SQLITE_INTEGER)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_NUMBER, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
            else if(sqliteType == SQLITE_FLOAT)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_NUMBER, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
        }
        
        //end of insert sql
        [sqlFormat appendString:DB_SQL_FORMAT_INSERT_END];
        
        //execute
        [dbDataUtil.sqliteUtil executeUpdate:sqlFormat];
    }
}

+ (void)deleteExtraIndexByDataTableName:(NSString *)dataTableName datas:(NSArray *)datas extraIndexNames:(NSArray *)extraIndexNames extraIndexValues:(NSArray *)extraIndexValues dbDataUtil:(DBDataUtil *)dbDataUtil
{
    if(datas == nil || datas.count == 0)
    {
        return;
    }
    
    int i;
    
    NSMutableString* sqlFormat = [[NSMutableString alloc] init];
    
    NSString* indexTableName = [ExtraIndexManager getExtraIndexTableNameByDataTableName:dataTableName];

    [sqlFormat appendFormat:DB_SQL_FORMAT_DELETE_SET_TABLE, indexTableName];
    [sqlFormat appendString:DB_SQL_FORMAT_WHERE];

    //conditions of extra index
    [sqlFormat appendFormat:DB_SQL_FORMAT_CONDITION_VALUE_STRING, [extraIndexNames objectAtIndex:0], [extraIndexValues objectAtIndex:0]];
    for(i = 1; i < extraIndexNames.count; i++)
    {
        [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_STRING, [extraIndexNames objectAtIndex:i], [extraIndexValues objectAtIndex:i]];
    }
    
    // set values of primary key ------------------------------------------------------------------
    //data pk column
    NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:[[datas objectAtIndex:0] class]];
    int sqliteType;
    PropertyInfo* propertyInfo = nil;
    
    DataTableSetting* dataTableSetting = [dbDataUtil getDataTableSetting:dataTableName];
    NSArray* dataPkArray = [dataTableSetting.primaryKeys componentsSeparatedByString:@","];
    NSMutableArray* propertyInfoArrayOfPKs = [[NSMutableArray alloc] init];
    for(i = 0; i < dataPkArray.count; i++)
    {
        propertyInfo = [propertyInfoDict objectForKey:[dataPkArray objectAtIndex:i]];
        
        [propertyInfoArrayOfPKs addObject:propertyInfo];
    }

    //sql
    [sqlFormat appendString:@" and ("];
    
    NSString* pkNameTmp = nil;
    id oneDataTmp = nil;
    
    for(int k = 0; k < datas.count; k++)
    {
        oneDataTmp = [datas objectAtIndex:k];
        
        if(k == 0)
        {
            [sqlFormat appendString:@" ("];
        }
        else
        {
            [sqlFormat appendString:@" or ("];
        }
        
        //handle one data row ----------------------
        for(i = 0; i < propertyInfoArrayOfPKs.count; i++)
        {
            propertyInfo = [propertyInfoArrayOfPKs objectAtIndex:i];
            pkNameTmp = [dataPkArray objectAtIndex:i];
            sqliteType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            
            if(sqliteType == SQLITE_TEXT)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_STRING, pkNameTmp,[SqliteUtil encodeQuoteChar:[oneDataTmp valueForKey:propertyInfo.propertyName]]];
            }
            else if(sqliteType == SQLITE_INTEGER)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, pkNameTmp, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
            else if(sqliteType == SQLITE_FLOAT)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, pkNameTmp, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
        }
        
        [sqlFormat appendString:@" ) "];
    }
    
    [sqlFormat appendString:@")"];
    [dbDataUtil.sqliteUtil executeUpdate:sqlFormat];
}

+ (void)deleteExtraIndexByDataTableName:(NSString *)dataTableName datas:(NSArray *)datas dbDataUtil:(DBDataUtil *)dbDataUtil
{
    int i;
    
    NSMutableString* sqlFormat = [[NSMutableString alloc] init];
    
    NSString* indexTableName = [ExtraIndexManager getExtraIndexTableNameByDataTableName:dataTableName];
    
    [sqlFormat appendFormat:DB_SQL_FORMAT_DELETE_SET_TABLE, indexTableName];
    [sqlFormat appendString:DB_SQL_FORMAT_WHERE];
        
    // set values of primary key ------------------------------------------------------------------
    //data pk column
    NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:[[datas objectAtIndex:0] class]];
    int sqliteType;
    PropertyInfo* propertyInfo = nil;
    
    DataTableSetting* dataTableSetting = [dbDataUtil getDataTableSetting:dataTableName];
    NSArray* dataPkArray = [dataTableSetting.primaryKeys componentsSeparatedByString:@","];
    NSMutableArray* propertyInfoArrayOfPKs = [[NSMutableArray alloc] init];
    for(i = 0; i < dataPkArray.count; i++)
    {
        propertyInfo = [propertyInfoDict objectForKey:[dataPkArray objectAtIndex:i]];
        
        [propertyInfoArrayOfPKs addObject:propertyInfo];
    }
    
    NSString* pkNameTmp = nil;
    id oneDataTmp = nil;
    
    for(int k = 0; k < datas.count; k++)
    {
        oneDataTmp = [datas objectAtIndex:k];
        
        if(k == 0)
        {
            [sqlFormat appendString:@" ("];
        }
        else
        {
            [sqlFormat appendString:@" or ("];
        }
        
        //handle one data row ----------------------
        for(i = 0; i < propertyInfoArrayOfPKs.count; i++)
        {
            propertyInfo = [propertyInfoArrayOfPKs objectAtIndex:i];
            pkNameTmp = [dataPkArray objectAtIndex:i];
            sqliteType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            
            if(sqliteType == SQLITE_TEXT)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_STRING, pkNameTmp,[SqliteUtil encodeQuoteChar:[oneDataTmp valueForKey:propertyInfo.propertyName]]];
            }
            else if(sqliteType == SQLITE_INTEGER)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, pkNameTmp, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
            else if(sqliteType == SQLITE_FLOAT)
            {
                [sqlFormat appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, pkNameTmp, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
        }
        
        [sqlFormat appendString:@" ) "];
    }
    
    [dbDataUtil.sqliteUtil executeUpdate:sqlFormat];
    
}

@end
