//
//  DBDataUtil.m
//  
//
//  Created by XingGu Liu on 12-5-17.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "DBDataUtil.h"
//#import "CloudDataConsts.h"
#import "DBDataSqlConsts.h"
#import "BaseTypesMapping.h"


@interface DBDataUtil(PrivateMethod)

- (void)checkDataTableSetting;

- (void)dropTableDirectly:(NSString *)tableName;
- (void)createTableDirectly:(Class)tableCls primaryKeys:(NSString*)primaryKeys;
- (void)createTableDirectly:(TableDesc*)tableDesc;

- (void)insertDataTableSetting:(NSString *)tableName primaryKeys:(NSString*)primaryKeys;
- (void)deleteDataTableSetting:(NSString *)tableName; 

-(NSSet*)createPrimaryKeySet:(NSString*)tableName;

-(void) appendWhereConditionOfPrimaryKeys:(NSMutableString*)sql tableName:(NSString*)tableName data:(id)data propertyArray:(NSArray*)propertyArray primaryKeySet:(NSSet*)primaryKeySet;

+(NSString*)getPropertyStringValueWithData:(id)data propertyInfo:(PropertyInfo*)propertyInfo;

@end

@implementation DBDataUtil

-(SqliteUtil*)sqliteUtil
{
    return _sqliteUtil;
}

-(id)init:(SqliteUtil*)sqliteUtil
{
    if(self = [super init])
    {
        _sqliteUtil = sqliteUtil;

        _dataTableSettingDict = [[NSMutableDictionary alloc] init];
        
        _primaryKeySetDict = [[NSMutableDictionary alloc] init];
        
        [self checkDataTableSetting];
    }
    
    return self;
}

-(void)close
{
    if(_sqliteUtil != nil)
    {
        [_sqliteUtil close];
        _sqliteUtil = nil;
    }
}

-(void)dealloc
{
    [_dataTableSettingDict removeAllObjects];
    _dataTableSettingDict = nil;

    [_primaryKeySetDict removeAllObjects];
    _primaryKeySetDict = nil;

#ifdef CLANG_OBJC_ARC_DISABLED
	[super dealloc];
#endif
}

- (void)checkDataTableSetting
{
    if(![self isTableExists:@"DataTableSetting"])
    {
        [self createTableDirectly:[DataTableSetting class] primaryKeys:@"tableName"];
    }
}

-(NSSet*) getPrimaryKeySet:(NSString*)tableName;
{
    NSSet* pkSet = [_primaryKeySetDict objectForKey:tableName];
    
    if(pkSet == nil)
    {
        pkSet = [self createPrimaryKeySet:tableName];
        
        [_primaryKeySetDict setObject:pkSet forKey:tableName];
    }
    
    return pkSet;
}

- (void)insertDataTableSetting:(NSString *)tableName primaryKeys:(NSString*)primaryKeys
{
    DataTableSetting* data = [[DataTableSetting alloc] init];
    
    data.tableName = tableName;
    data.primaryKeys = primaryKeys;
    data.tableType = 2;
    
    [self insertData:@"DataTableSetting" data:data];
}

- (void)deleteDataTableSetting:(NSString *)tableName
{
    NSString* sql = [NSString stringWithFormat:CLOUD_DATA_SQL_FORMAT_DELETE_DATA_TABLE_SETTING, tableName];
    [self.sqliteUtil executeUpdate:sql];
}

-(DataTableSetting*) getDataTableSetting:(NSString*)tableName
{
    DataTableSetting* dataTableSetting = nil;
    
    dataTableSetting = [_dataTableSettingDict objectForKey:tableName];

    if(dataTableSetting == nil)
    {
        NSString* sql = [NSString stringWithFormat:DB_SQL_FORMAT_SELECT_DATA_TABLE_SETTING, tableName];
        DataTableSetting* dataTableSetting1 = [_sqliteUtil findData:sql dataType:[DataTableSetting class]];
        
        [_dataTableSettingDict setObject:dataTableSetting1 forKey:tableName];
        
        return dataTableSetting1;
    }
    else 
    {
        return dataTableSetting;
    }
}

-(NSArray*) getAllDataTableSetting
{
    return [self findAllData:@"DataTableSetting"];
}

- (bool)isTableExists:(NSString *)tableName
{
    int count = [self.sqliteUtil executeIntScalar:[NSString stringWithFormat:@"select count(1) from sqlite_master where type = 'table' and upper(name) = upper('%@')", tableName]];
    
    if(count > 0)
    {
        return true;
    }
    else {
        return false;
    }
}

- (void)dropTableDirectly:(NSString *)tableName
{
    [self.sqliteUtil executeUpdate:[NSString stringWithFormat:@"drop table if exists %@", tableName]];
}

-(void)createTableDirectly:(Class)tableCls primaryKeys:(NSString*)primaryKeys
{
    NSString* tableName = NSStringFromClass(tableCls);
    NSMutableString* createSql = [NSMutableString stringWithFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_TABLE_NAME, tableName];
    
    NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:tableCls];
    int sqliteColumnType;
    for (PropertyInfo* propertyInfo in propertyArray) {
        sqliteColumnType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
        if(sqliteColumnType == SQLITE_TEXT)
        {
            [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_TEXT, propertyInfo.propertyName];
        }
        else if(sqliteColumnType == SQLITE_INTEGER)
        {
            [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_INTEGER, propertyInfo.propertyName];
        }
        else if(sqliteColumnType == SQLITE_FLOAT)
        {
            [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_REAL, propertyInfo.propertyName];
        }
    }
    
//    if([tableCls isSubclassOfClass:[BaseDataTable class]])
//    {
//        [createSql appendString:DB_SQL_FORMAT_BASE_DATA_BASE_COLUMNS];
//    }
    
    
    [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_PRIMARY_KEY, primaryKeys];
    
    [createSql appendString:DB_SQL_FORMAT_CREATE_TABLE_END];
    
    SSLogDebug(@"createTable: %@", createSql);
    
    propertyArray = nil;
    
    //execute sql
    [self.sqliteUtil executeUpdate:createSql];
}

- (void)createTableDirectly:(TableDesc *)tableDesc
{
    NSString* tableName = tableDesc.tableName;
    NSMutableString* createSql = [NSMutableString stringWithFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_TABLE_NAME, tableName];
    
    ColDesc* colDesc = nil;
    NSString* colType = nil;
    for (int i = 0; i < tableDesc.colDescList.count; i++) {
        colDesc = [tableDesc.colDescList objectAtIndex:i];
        colType = [colDesc.colType lowercaseString];
        if([colType isEqualToString:@"text"])
        {
            [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_TEXT, colDesc.colName];
        }
        else if([colType isEqualToString:@"real"])
        {
            [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_REAL, colDesc.colName];
        }
        else
        {
            [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_INTEGER, colDesc.colName];
        }
    }
    
    
    [createSql appendFormat:DB_SQL_FORMAT_CREATE_TABLE_SET_PRIMARY_KEY, tableDesc.primaryKeys];
    
    [createSql appendString:DB_SQL_FORMAT_CREATE_TABLE_END];
    
    SSLogDebug(@"createTable: %@", createSql);
    
    //execute sql
    [self.sqliteUtil executeUpdate:createSql];
}

-(void)dropTable:(NSString*)tableName
{
    [self dropTableDirectly:tableName];
    [self deleteDataTableSetting:tableName];
}

-(void)createTable:(Class)tableCls primaryKeys:(NSString*)primaryKeys
{
    [self createTableDirectly:tableCls primaryKeys:primaryKeys];
    [self insertDataTableSetting:NSStringFromClass(tableCls) primaryKeys:primaryKeys];
}

- (void)createTable:(TableDesc *)tableDesc
{
    [self createTableDirectly:tableDesc];
    [self insertDataTableSetting:tableDesc.tableName primaryKeys:tableDesc.primaryKeys];
}

-(int)insertData:(NSString*)tableName data:(id __unsafe_unretained)data
{
    NSMutableString* sql = nil;
    NSString* strTmp = nil;
    
    @try {
        strTmp = [NSString stringWithFormat:DB_SQL_FORMAT_INSERT_SET_TABLE, tableName];
        sql = [[NSMutableString alloc] initWithString:strTmp];
        strTmp = nil;
        
        
        NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:[data class]];
        PropertyInfo* propertyInfo;
        
        //Set column name
        propertyInfo = [propertyArray objectAtIndex:0];
        [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_0, propertyInfo.propertyName];
        
        int i;
        int propertyCount = propertyArray.count;
        for(i = 1; i < propertyCount; i++)
        {
            propertyInfo = [propertyArray objectAtIndex:i];
            
            [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN, propertyInfo.propertyName];
        }
        
        [sql appendString:DB_SQL_FORMAT_INSERT_SET_COLUMN_END];
        
        //set column value
        propertyInfo = [propertyArray objectAtIndex:0];
        int sqliteType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
        
        if(sqliteType == SQLITE_TEXT)
        {
            [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_STRING, [SqliteUtil encodeQuoteChar:[DBDataUtil getPropertyStringValueWithData:data propertyInfo:propertyInfo]]];
        }
        else if(sqliteType == SQLITE_INTEGER)
        {
            [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_NUMBER, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
        }
        else if(sqliteType == SQLITE_FLOAT)
        {
            [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_NUMBER, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
        }
        
        for(i = 1; i < propertyCount; i++)
        {
            propertyInfo = [propertyArray objectAtIndex:i];
            sqliteType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            
            if(sqliteType == SQLITE_TEXT)
            {
                [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_STRING, [SqliteUtil encodeQuoteChar:[DBDataUtil getPropertyStringValueWithData:data propertyInfo:propertyInfo ]]];
            }
            else if(sqliteType == SQLITE_INTEGER)
            {
                [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_NUMBER, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
            }
            else if(sqliteType == SQLITE_FLOAT)
            {
                [sql appendFormat:DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_NUMBER, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
            }
        }
        
        [sql appendString:DB_SQL_FORMAT_INSERT_END];
        
        //execute
        return [_sqliteUtil executeUpdate:sql];

    }
    @finally {
        sql = nil;
        strTmp = nil;
    }
}

-(int)insertData:(NSString*)tableName dataXml:(NSString*)dataXml
{
    Class dataType = NSClassFromString(tableName);
    
    id data = [SimpleMetoXML stringToObject:dataXml dataType:dataType];
    
    return [self insertData:tableName data:data];
}

/*
 the where sql is made of the primary keys.
 */
-(int)updateDataByPK:(NSString*)tableName data:(id __unsafe_unretained)data
{
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_UPDATE_SET_TABLE, tableName];
    
    NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:[data class]];
    
    NSSet* pkSet = [self getPrimaryKeySet:tableName];
    
    //set column value
    int index = 0;
    int sqliteColType;
    for(PropertyInfo* propertyInfo in propertyArray)
    {
        if(![pkSet containsObject:propertyInfo.propertyName])
        {
            sqliteColType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            
            if(sqliteColType == SQLITE_TEXT)
            {
                if(index== 0)
                {
                    [sql appendFormat:DB_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_STRING, propertyInfo.propertyName, [SqliteUtil encodeQuoteChar:[DBDataUtil getPropertyStringValueWithData:data propertyInfo:propertyInfo]]];
                }
                else
                {
                    [sql appendFormat:DB_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_STRING, propertyInfo.propertyName, [SqliteUtil encodeQuoteChar:[DBDataUtil getPropertyStringValueWithData:data propertyInfo:propertyInfo]]];
                }
            }
            else if(sqliteColType == SQLITE_INTEGER)
            {
                if(index == 0)
                {
                    [sql appendFormat:DB_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
                else
                {
                    [sql appendFormat:DB_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
            }
            else if(sqliteColType == SQLITE_FLOAT)
            {
                if(index == 0)
                {
                    [sql appendFormat:DB_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
                else
                {
                    [sql appendFormat:DB_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
            }
            else 
            {
                continue;
            }//if
            
            index++;
        }//if
        
    }//for
    
    [sql appendString:DB_SQL_FORMAT_WHERE];
    
    //set where condition
    [self appendWhereConditionOfPrimaryKeys:sql tableName:tableName data:data propertyArray:propertyArray primaryKeySet:pkSet];
    
    //execute
    int returnCode = [_sqliteUtil executeUpdate:sql];
    
    propertyArray = nil;
    sql = nil;
    
    return returnCode;
}

-(int)updateDataByPK:(NSString*)tableName dataXml:(NSString*)dataXml
{
    Class dataType = NSClassFromString(tableName);
    id data = [SimpleMetoXML stringToObject:dataXml dataType:dataType];
    
    int returnCode = [self updateDataByPK:tableName data:data];
    
    data = nil;
    
    return returnCode;
}

-(int)insertOrUpdateDataByPK:(NSString*)tableName data:(id __unsafe_unretained)data
{
    int returnCode = 1;
    
    @try {
        returnCode = [self insertData:tableName data:data];
    }
    @catch (NSException *exception) {
        returnCode = 0;
    }
    
    if(returnCode == 0)
    {
        @try {
            return [self updateDataByPK:tableName data:data];
        }
        @catch (NSException *exception) {
            SSLogDebug(@"insertOrUpdateDataByPK():Error Occurred. tableName:%@", tableName);
            return 0;
        }
        @finally {
        }
    }
    
    return returnCode;
}


//-(void)updateData:(NSString*)tableName dataXml:(NSString*)dataXml dataType:(Class)dataType;

/*
 the where sql is made of the primary keys.
 */
-(int)deleteDataByPK:(NSString*)tableName data:(id)data
{
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_DELETE_SET_TABLE, tableName];
    
    NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:[data class]];
    NSSet* pkSet = [self getPrimaryKeySet:tableName];
    
    [sql appendString:DB_SQL_FORMAT_WHERE];
    
    //set where condition
    [self appendWhereConditionOfPrimaryKeys:sql tableName:tableName data:data propertyArray:propertyArray primaryKeySet:pkSet];
    
    //execute
    int returnCode = [_sqliteUtil executeUpdate:sql];
    
    propertyArray = nil;
    sql = nil;
    
    return returnCode;
}

-(int)deleteDataByPK:(NSString*)tableName dataXml:(NSString*)dataXml
{
    Class dataType = NSClassFromString(tableName);
    id data = [SimpleMetoXML stringToObject:dataXml dataType:dataType];
    
    int returnCode = [self deleteDataByPK:tableName data:data];
    
    data = nil;
    
    return returnCode;
}

//-(void)deleteData:(NSString*)tableName dataXml:(NSString*)dataXml dataType:(Class)dataType;

-(int)deleteAllData:(NSString*)tableName
{
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_DELETE_SET_TABLE, tableName];
    
    //execute
    int returnCode = [_sqliteUtil executeUpdate:sql];
    
    sql = nil;
    
    return returnCode;
}


/*
 the where sql is made of the primary keys.
 */
-(id)findDataByPK:(NSString*)tableName data:(id)data
{
    //CLOUD_DATA_SQL_FORMAT_SELECT_SET_TABLE
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_SELECT_SET_TABLE, tableName];
    
    NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:[data class]];
    NSSet* pkSet = [self getPrimaryKeySet:tableName];
    
    [sql appendString:DB_SQL_FORMAT_WHERE];
    
    //set where condition
    [self appendWhereConditionOfPrimaryKeys:sql tableName:tableName data:data propertyArray:propertyArray primaryKeySet:pkSet];
    
    //execute
    id dataResult = [_sqliteUtil findData:sql dataType:[data class]];
    
    propertyArray = nil;
    sql = nil;
    
    return dataResult;
}

-(id)findDataByPK:(NSString*)tableName dataXml:(NSString*)dataXml
{
    id data = [SimpleMetoXML stringToObject:dataXml dataType:NSClassFromString(tableName)];
    
    id dataResult = [self findDataByPK:tableName data:data];
    
    data = nil;
    
    return dataResult;
}

-(NSString*)findDataXmlByPK:(NSString*)tableName data:(id)data
{
    //CLOUD_DATA_SQL_FORMAT_SELECT_SET_TABLE
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_SELECT_SET_TABLE, tableName];
    
    NSArray* propertyArray = [PropertyInfoUtil getPropertyInfoArray:[data class]];
    NSSet* pkSet = [self getPrimaryKeySet:tableName];
    
    [sql appendString:DB_SQL_FORMAT_WHERE];
    
    //set where condition
    [self appendWhereConditionOfPrimaryKeys:sql tableName:tableName data:data propertyArray:propertyArray primaryKeySet:pkSet];
    
    //execute
    NSString* dataXmlResult = [_sqliteUtil findDataXml:sql dataTypeName:tableName];
    
    propertyArray = nil;
    sql = nil;
    
    return dataXmlResult;
}

-(NSString*)findDataXmlByPK:(NSString*)tableName dataXml:(NSString*)dataXml
{
    id data = [SimpleMetoXML stringToObject:dataXml dataType:NSClassFromString(tableName)];
    
    NSString* dataXmlResult =  [self findDataXmlByPK:tableName data:data];
    
    data = nil;
    
    return dataXmlResult;
}


-(NSArray*) findAllData:(NSString*)tableName
{
    //CLOUD_DATA_SQL_FORMAT_SELECT_SET_TABLE
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_SELECT_SET_TABLE, tableName];
    
    NSArray* dataArrayResult = [_sqliteUtil findDataList:sql dataType:NSClassFromString(tableName)];
    
    sql = nil;
    
    return dataArrayResult;
}

-(NSString*) findAllDataXml:(NSString*)tableName
{
    //CLOUD_DATA_SQL_FORMAT_SELECT_SET_TABLE
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_SELECT_SET_TABLE, tableName];
    
    NSString* dataXmlResult = [_sqliteUtil findDataListXml:sql dataTypeName:tableName];
    
    sql = nil;
    
    return dataXmlResult;
}

/* Deprecated
-(NSArray*) findDataAfterUpdateTime:(NSString*)tableName updateTime:(long long)updateTime
{
    //CLOUD_DATA_SQL_FORMAT_SELECT_SET_TABLE
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_SELECT_SET_TABLE, tableName];
    
    [sql appendString:DB_SQL_FORMAT_WHERE];
    
    [sql appendFormat:DB_SQL_FORMAT_CONDITION_VALUE_NUMBER, DB_SQL_DATA_COLUMN_UPDATE_TIME, [[NSNumber numberWithLongLong:updateTime] stringValue]];
    
    NSArray* dataArray = [_sqliteUtil findDataList:sql dataType:NSClassFromString(tableName)];
    
    sql = nil;
    
    return dataArray;
}

-(NSString*) findDataXmlAfterUpdateTime:(NSString*)tableName updateTime:(long long)updateTime
{
    //CLOUD_DATA_SQL_FORMAT_SELECT_SET_TABLE
    NSMutableString* sql = [[NSMutableString alloc] initWithFormat:DB_SQL_FORMAT_SELECT_SET_TABLE, tableName];
    
    [sql appendString:DB_SQL_FORMAT_WHERE];
    
    [sql appendFormat:DB_SQL_FORMAT_CONDITION_VALUE_NUMBER, DB_SQL_DATA_COLUMN_UPDATE_TIME, [[NSNumber numberWithLongLong:updateTime] stringValue]];
    
    NSString* dataArrayXml = [_sqliteUtil findDataListXml:sql dataTypeName:tableName];
    
    sql = nil;
    
    return dataArrayXml;
}
*/

-(NSArray*) findData:(NSString*)sql dataType:(Class)dataType
{
    NSArray* dataArray = [_sqliteUtil findDataList:sql dataType:dataType];
    
    return dataArray;
}
-(NSString*) findDataXml:(NSString*)sql dataTypeName:(NSString*)dataTypeName
{
    return [_sqliteUtil findDataListXml:sql dataTypeName:dataTypeName];
}


/***** Private Methods *****/
-(NSSet*) createPrimaryKeySet:(NSString*)tableName
{
    DataTableSetting* dataTableSetting = [self getDataTableSetting:tableName];
    
    NSArray* pks = [dataTableSetting.primaryKeys componentsSeparatedByString:@","];
    NSSet* pkSet = [[NSSet alloc] initWithArray:pks];
    
    return pkSet;
}

-(void) appendWhereConditionOfPrimaryKeys:(NSMutableString*)sql tableName:(NSString*)tableName data:(id)data propertyArray:(NSArray*)propertyArray primaryKeySet:(NSSet*)primaryKeySet
{
    int index = 0;
    int sqliteColType;
    
    for(PropertyInfo* propertyInfo in propertyArray)
    {
        if([primaryKeySet containsObject:propertyInfo.propertyName])
        {
            sqliteColType = [SqliteUtil getSQLiteColumnTypeByPropertyType:propertyInfo.propertyType];
            
            if(sqliteColType == SQLITE_TEXT)
            {
                if(index== 0)
                {
                    [sql appendFormat:DB_SQL_FORMAT_CONDITION_VALUE_STRING, propertyInfo.propertyName, [SqliteUtil encodeQuoteChar:[DBDataUtil getPropertyStringValueWithData:data propertyInfo:propertyInfo]]];
                }
                else
                {
                    [sql appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_STRING, propertyInfo.propertyName, [SqliteUtil encodeQuoteChar:[DBDataUtil getPropertyStringValueWithData:data propertyInfo:propertyInfo]]];
                }
            }
            else if(sqliteColType == SQLITE_INTEGER)
            {
                if(index == 0)
                {
                    [sql appendFormat:DB_SQL_FORMAT_CONDITION_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
                else
                {
                    [sql appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
            }
            else if(sqliteColType == SQLITE_FLOAT)
            {
                if(index == 0)
                {
                    [sql appendFormat:DB_SQL_FORMAT_CONDITION_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
                else
                {
                    [sql appendFormat:DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER, propertyInfo.propertyName, [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo]];
                }
            }
            else {
                continue;
            }//if
            
            index++;
        }//if
        
    }//for
    
}

+(NSString*)getPropertyStringValueWithData:(id)data propertyInfo:(PropertyInfo*)propertyInfo
{
    NSString* strVal = [BaseTypesMapping getPropertyStringValueWithData:data propertyInfo:propertyInfo];
    if(strVal == nil)
    {
        return @"";
    }
    else
    {
        return strVal;
    }
}


@end
