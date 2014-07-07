//
//  LocalStorageService.m
//  SalamaDataService
//
//  Created by Liu XingGu on 12-9-29.
//
//

#import "LocalStorageService.h"

#import "ExtraIndexManager.h"
#import "DBDataSqlConsts.h"

@implementation LocalStorageService

- (void)storeDataToTable:(NSString *)tableName datas:(NSArray *)datas extraIndexNames:(NSArray *)extraIndexNames extraIndexValues:(NSArray *)extraIndexValues dbDataUtil:(DBDataUtil *)dbDataUtil
{
    if(datas == nil || datas.count == 0
       || tableName == nil || tableName.length == 0)
    {
        return;
    }
    
    id dataTmp = nil;
    BOOL hasExtraIndex = NO;
    
    if(extraIndexNames != nil && extraIndexNames.count > 0)
    {
        hasExtraIndex = YES;
    }
    
    NSMutableArray* insertedDatas = [[NSMutableArray alloc] init];

    for(int i = 0; i < datas.count; i++)
    {
        dataTmp = [datas objectAtIndex:i];
        
        //store data
        @try {
            //insert 
            [dbDataUtil insertData:tableName data:dataTmp];
            
            [insertedDatas addObject:dataTmp];
        }
        @catch (NSException *exception) {
            @try {
                //update
                [dbDataUtil updateDataByPK:tableName data:dataTmp];
            }
            @finally {
            }
        }
    }
    
    //add the extra index row
    if(hasExtraIndex)
    {
        [ExtraIndexManager insertExtraIndexWithDataTableName:tableName datas:insertedDatas extraIndexNames:extraIndexNames extraIndexValues:extraIndexValues dbDataUtil:dbDataUtil];
    }
    
    [insertedDatas removeAllObjects];
}

- (void)removeDataAndExtraIndexForTable:(NSString *)tableName datas:(NSArray *)datas dbDataUtil:(DBDataUtil *)dbDataUtil
{
    if(datas == nil || datas.count == 0
       || tableName == nil || tableName.length == 0)
    {
        return;
    }
    
    int i;
    
    // where conditions of data primary keys ------------------------------------------------------------------
    //data pk column
    NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:[[datas objectAtIndex:0] class]];
    int sqliteType;
    PropertyInfo* propertyInfo = nil;
    
    DataTableSetting* dataTableSetting = [dbDataUtil getDataTableSetting:tableName];
    NSArray* dataPkArray = [dataTableSetting.primaryKeys componentsSeparatedByString:@","];
    NSMutableArray* propertyInfoArrayOfPKs = [[NSMutableArray alloc] init];
    for(i = 0; i < dataPkArray.count; i++)
    {
        propertyInfo = [propertyInfoDict objectForKey:[dataPkArray objectAtIndex:i]];
        
        [propertyInfoArrayOfPKs addObject:propertyInfo];
    }
    
    //sql of conditions
    NSMutableString* sqlOfWhereConditionPart = [[NSMutableString alloc] init];
    NSString* pkNameTmp = nil;
    id oneDataTmp = nil;
    
    for(int k = 0; k < datas.count; k++)
    {
        oneDataTmp = [datas objectAtIndex:k];
        
        if(k == 0)
        {
            [sqlOfWhereConditionPart appendString:@" ("];
        }
        else
        {
            [sqlOfWhereConditionPart appendString:@" or ("];
        }
        
        //handle one data row ----------------------
        for(i = 0; i < propertyInfoArrayOfPKs.count; i++)
        {
            propertyInfo = [propertyInfoArrayOfPKs objectAtIndex:i];
            pkNameTmp = [dataPkArray objectAtIndex:i];
            sqliteType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            
            if(sqliteType == SQLITE_TEXT)
            {
                [sqlOfWhereConditionPart appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_STRING, pkNameTmp,[SqliteUtil encodeQuoteChar:[oneDataTmp valueForKey:propertyInfo.propertyName]]];
            }
            else if(sqliteType == SQLITE_INTEGER)
            {
                [sqlOfWhereConditionPart appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, pkNameTmp, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
            else if(sqliteType == SQLITE_FLOAT)
            {
                [sqlOfWhereConditionPart appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, pkNameTmp, [BaseTypesMapping getPropertyStringValueWithData:oneDataTmp propertyInfo:propertyInfo]];
            }
        }
        
        [sqlOfWhereConditionPart appendString:@" ) "];
    }
    
    //delete data rows -----------------------------------------------
    {
        NSMutableString* sqlOfDeleteData = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_DELETE_SET_TABLE, tableName];
        [sqlOfDeleteData appendString:DB_SQL_FORMAT_WHERE];
        [sqlOfDeleteData appendString:sqlOfWhereConditionPart];
        
        [dbDataUtil.sqliteUtil executeUpdate:sqlOfDeleteData];
    }
    
    //delete extra index rows ----------------------------------------
    {
        NSString* indexTableName = [ExtraIndexManager getExtraIndexTableNameByDataTableName:tableName];
        NSMutableString* sqlOfDeleteExtraIndex = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_DELETE_SET_TABLE, indexTableName];
        [sqlOfDeleteExtraIndex appendString:DB_SQL_FORMAT_WHERE];
        [sqlOfDeleteExtraIndex appendString:sqlOfWhereConditionPart];
        
        [dbDataUtil.sqliteUtil executeUpdate:sqlOfDeleteExtraIndex];
    }
}

@end
