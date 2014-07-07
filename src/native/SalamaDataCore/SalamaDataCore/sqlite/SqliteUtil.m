//
//  SqliteUtil.m
//  WorkHarder
//
//  Created by XingGu Liu on 12-5-6.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "SqliteUtil.h"
#import "SqliteException.h"

#define SQLITE_UTIL_LOG_ENABLE 1

@interface SqliteUtil(PrivateMethod)

+ (void)logException:(NSException *)exception;

+ (NSString *)errorMsgOfException:(NSException *)exception;

-(void)handleError:(int)errorCode operation:(NSString*)operation;

-(void)handleErrorWithErrorMsg:(int)errorCode operation:(NSString*)operation;

-(void)setDataProperty:(id)data propertyInfo:(PropertyInfo*)propertyInfo longlongValue:(long long)longlongValue;
-(void)setDataProperty:(id)data propertyInfo:(PropertyInfo*)propertyInfo stringValue:(NSString*)strValue;
-(void)setDataProperty:(id)data propertyInfo:(PropertyInfo*)propertyInfo doubleValue:(double)doubleValue;

-(id)fetchRowForBaseType:(sqlite3_stmt*)stmt dataType:(Class)dataType;

-(id)fetchRowForDataType:(sqlite3_stmt*)stmt colCount:(int)colCount dataType:(Class)dataType propertyInfoDict:(NSDictionary*)propertyInfoDict;

-(void)fetchRowIntoXml:(NSMutableString*)xml stmt:(sqlite3_stmt*)stmt colCount:(int)colCount nodeName:(NSString*)nodeName;

-(NSString*)fetchTextValueOfColIndex:(int)colIndex stmt:(sqlite3_stmt*)stmt;

@end

@implementation SqliteUtil
static NSString* SQLITE_UTIL_TAG_NAME_BEGIN_FORMAT = @"<%@>"; 
static NSString* SQLITE_UTIL_TAG_NAME_END_FORMAT = @"</%@>"; 

static NSString* SQLITE_UTIL_TAG_NAME_FORMAT_STRING = @"<%@>%@</%@>";

static NSString* SQLITE_UTIL_TAG_NAME_FORMAT_LONG = @"<%@>%lld</%@>";

static NSString* SQLITE_UTIL_TAG_NAME_FORMAT_DOUBLE = @"<%@>%Lf</%@>";

static NSString* SQLITE_UTIL_TAG_NAME_BEGIN_LIST = @"<List>";
static NSString* SQLITE_UTIL_TAG_NAME_END_LIST = @"</List>";

static NSLock* _sqliteLock = nil;

+(NSString*) encodeQuoteChar:(NSString*)strValue
{
    if(strValue == nil)
    {
        return @"";
    }
    else
    {
        return [strValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
}

+(int)getSQLiteColumnTypeByPropertyType:(PropertyType)propertyType
{
    if(propertyType == PropertyType_NSString
       || propertyType == PropertyType_NSData
       || propertyType == PropertyType_NSDate
       || propertyType == PropertyType_bool
       || propertyType == PropertyType_NSDecimalNumber)
    {
        return SQLITE_TEXT;
    }
    else if(propertyType == PropertyType_double
            || propertyType == PropertyType_float)
    {
        return SQLITE_FLOAT;
    }
    else 
    {
        return SQLITE_INTEGER;
    }
}

+(SqliteUtil *)sqliteUtilWithDBFilePath:(NSString *)dbFilePath
{
    return [[SqliteUtil alloc] init:dbFilePath];
}

+ (void)logException:(NSException *)exception
{
    NSString* errorMsg = [SqliteUtil errorMsgOfException:exception];
    
    NSLog(errorMsg);
}

+ (NSString *)errorMsgOfException:(NSException *)exception
{
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; // 将调用栈拼成输出日志的字符串
    for (NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    return [NSString stringWithFormat:@"%@:%@\n%@", exception.name, exception.reason, symbols];
}

-(id) init:(NSString*) dbFilePath
{
	if(self=[super init])
    {
        _dbFilePath = [NSString stringWithString:dbFilePath];
        if(_sqliteLock == nil)
        {
            _sqliteLock = [[NSLock alloc] init];
        }
    }
    
    return self;
}

-(void) open
{
    int errorCode = sqlite3_open([_dbFilePath UTF8String], &_db);
       
    [self handleError:errorCode operation:@"sqlite3_open"];
}

-(void) close
{
    int errorCode = sqlite3_close(_db);
    
    [self handleError:errorCode operation:@"sqlite3_close"];
}

-(sqlite3*) db
{
    return _db;
}

-(NSString*) dbFilePath
{
    return [_dbFilePath copy];
}

/*
-(NSSet*) getPrimaryKeySet:(Class)dataType
{
    int errorCode;
    
    //char* cDataType;
    //char* cCollSeq;
    int isNotNull;
    int isPK;
    int isAutoInc;
    
    NSString* tableName = NSStringFromClass(dataType);
    
    NSArray* propertyInfos = [DataPropertyInfoUtil getPropertyInfos:dataType];
    
    NSMutableSet* pkSet = [[NSMutableSet alloc] init];
    
    for(DataPropertyInfo* propertyInfo in propertyInfos)
    {
        errorCode = sqlite3_table_column_metadata(_db, "main", [tableName UTF8String], [[propertyInfo propertyName] UTF8String], NULL, NULL, &isNotNull, &isPK, &isAutoInc);
        [self handleError:errorCode operation:@"sqlite3_table_column_metadata"];
        
        if(isPK != 0)
        {
            [pkSet addObject:propertyInfo.propertyName];
        }
    }
    
    tableName = nil;
    propertyInfos = nil;
    
    return pkSet;
}
*/

-(int) executeIntScalar:(NSString*)sql
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"executeIntScalar():%@", sql);
#endif

    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        int colIndex = 0;
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            return sqlite3_column_int(stmt, colIndex);
        } 
        else 
        {
            return 0;
        }
        
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {        
        sqlite3_finalize(stmt);
        stmt = nil;
        [_sqliteLock unlock];
    }
}
-(long long) executeLongScalar:(NSString*)sql
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"executeLongScalar():%@", sql);
#endif
    
    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        int colIndex = 0;
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            return sqlite3_column_int64(stmt, colIndex);
        } 
        else 
        {
            return 0;
        }
        
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {        
        sqlite3_finalize(stmt);
        stmt = nil;
        
        [_sqliteLock unlock];
    }
}

-(double) executeDoubleScalar:(NSString*)sql
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"executeDoubleScalar():%@", sql);
#endif
    
    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        int colIndex = 0;
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            return sqlite3_column_double(stmt, colIndex);
        } 
        else 
        {
            return 0;
        }
        
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {        
        sqlite3_finalize(stmt);
        stmt = nil;
        
        [_sqliteLock unlock];
    }
}

-(NSString*) executeStringScalar:(NSString*)sql
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"executeStringScalar():%@", sql);
#endif
    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        int colIndex = 0;
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            //return [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, colIndex)];
            return [self fetchTextValueOfColIndex:colIndex stmt:stmt];
        } 
        else 
        {
            return nil;
        }
        
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {        
        sqlite3_finalize(stmt);
        stmt = nil;
        
        [_sqliteLock unlock];
    }
}

-(NSArray*) findDataList:(NSString*)sql dataType:(Class)dataType;
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"findDataList():%@", sql);
#endif

    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        int colCount = sqlite3_column_count(stmt);
        
        NSMutableArray* dataArray = [[NSMutableArray alloc] init];
        
        BOOL isBaseObjectType = NO;
        if(colCount == 1 && [BaseTypesMapping isSupportedBaseObjectType:dataType])
        {
            isBaseObjectType = YES;
        }
        
        if(isBaseObjectType)
        {
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                [dataArray addObject:[self fetchRowForBaseType:stmt dataType:dataType]];
            }
        }
        else
        {
            NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:dataType];
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                [dataArray addObject:[self fetchRowForDataType:stmt colCount:colCount dataType:dataType propertyInfoDict:propertyInfoDict]];
            }
        }
        
        return dataArray;
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {
        sqlite3_finalize(stmt);
        
        [_sqliteLock unlock];
    }
}

-(id) findData:(NSString*)sql dataType:(Class)dataType;
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"findData():%@", sql);
#endif
    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        int colCount = sqlite3_column_count(stmt);

        BOOL isBaseObjectType = NO;
        if(colCount == 1 && [BaseTypesMapping isSupportedBaseObjectType:dataType])
        {
            isBaseObjectType = YES;
        }
        
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            if(isBaseObjectType)
            {
                return [self fetchRowForBaseType:stmt dataType:dataType];
            }
            else 
            {
                NSDictionary* propertyInfoDict = [PropertyInfoUtil getPropertyInfoMap:dataType];
                
                id result = [self fetchRowForDataType:stmt colCount:colCount dataType:dataType propertyInfoDict:propertyInfoDict];
                
                propertyInfoDict = nil;
                
                return result;
            }
        } 
        else 
        {
            return nil;
        }
        
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {        
        sqlite3_finalize(stmt);
        stmt = nil;
        
        [_sqliteLock unlock];
    }
}

-(int) executeUpdate:(NSString*)sql
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"executeUpdate():%@", sql);
#endif

    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &_errorMsg);
        
        [self handleErrorWithErrorMsg:errorCode operation:@"sqlite3_exec"];
        
        return (errorCode == SQLITE_OK?1:0);
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
        return 0;
    }
    @finally {
        [_sqliteLock unlock];
    }
    
}


-(NSString*) findDataListXml:(NSString*)sql dataTypeName:(NSString*)dataTypeName;
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"findDataListXml():%@", sql);
#endif
    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        NSMutableString* xml = [[NSMutableString alloc] init];
        
        [xml appendString:SQLITE_UTIL_TAG_NAME_BEGIN_LIST];
        
        int colCount = sqlite3_column_count(stmt);

        while(sqlite3_step(stmt) == SQLITE_ROW)
        {
            [self fetchRowIntoXml:xml stmt:stmt colCount:colCount nodeName:dataTypeName];
        } 

        [xml appendString:SQLITE_UTIL_TAG_NAME_END_LIST];
        
        return xml;
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {
        sqlite3_finalize(stmt);
        
        [_sqliteLock unlock];
    }
}

-(NSString*) findDataXml:(NSString*)sql dataTypeName:(NSString*)dataTypeName;
{
#if SQLITE_UTIL_LOG_ENABLE
    SSLogDebug(@"findDataXml():%@", sql);
#endif
    sqlite3_stmt* stmt;
    
    @try {
        [_sqliteLock lock];
        
        int errorCode = sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL);
        [self handleError:errorCode operation:@"sqlite3_prepare_v2"];
        
        NSMutableString* xml = [[NSMutableString alloc] init];

        int colCount = sqlite3_column_count(stmt);
        
        if(sqlite3_step(stmt) == SQLITE_ROW)
        {
            [self fetchRowIntoXml:xml stmt:stmt colCount:colCount nodeName:dataTypeName];
        } 

        return xml;
    }
    @catch (NSException *exception) {
        //@throw exception;
        [SqliteUtil logException:exception];
    }
    @finally {
        sqlite3_finalize(stmt);
        
        [_sqliteLock unlock];
    }
}

-(void)setDataProperty:(id)data propertyInfo:(PropertyInfo*)propertyInfo longlongValue:(long long)longlongValue
{
    [data setValue:[NSNumber numberWithLongLong:longlongValue] forKey:propertyInfo.propertyName];
}

-(void)setDataProperty:(id)data propertyInfo:(PropertyInfo*)propertyInfo stringValue:(NSString*)strValue
{
    [BaseTypesMapping setPropertyValueWithStringValue:strValue data:data propertyInfo:propertyInfo];
}

-(void)setDataProperty:(id)data propertyInfo:(PropertyInfo*)propertyInfo doubleValue:(double)doubleValue
{
    [data setValue:[NSNumber numberWithDouble:doubleValue] forKey:propertyInfo.propertyName];
}

-(id)fetchRowForBaseType:(sqlite3_stmt*)stmt dataType:(Class)dataType
{
    int colIndex = 0;
    int colType = sqlite3_column_type(stmt, colIndex);
    
    if(colType == SQLITE_TEXT)
    {
        //NSString* strVal = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, colIndex)];
        NSString* strVal = [self fetchTextValueOfColIndex:colIndex stmt:stmt];
        return [BaseTypesMapping getSupportedBaseObjectByString:strVal type:dataType];
    }
    else if(colType == SQLITE_INTEGER)
    {
        long long longVal = sqlite3_column_int64(stmt, colIndex);
        return [[NSDecimalNumber alloc] initWithLongLong:longVal];
    }
    else if(colType == SQLITE_FLOAT)
    {
        double doubleVal = sqlite3_column_double(stmt, colIndex);
        return [[NSDecimalNumber alloc] initWithDouble:doubleVal];
    }
    else 
    {
        return nil;
    }
    
}

-(id)fetchRowForDataType:(sqlite3_stmt*)stmt colCount:(int)colCount dataType:(Class)dataType propertyInfoDict:(NSDictionary*)propertyInfoDict
{
    const char* colName;
    int colType = 0;
    
    id data = [[dataType alloc] init];
    
    PropertyInfo* propertyInfo;
    
    for(int colIndex = 0; colIndex < colCount; colIndex++)
    {
        colType = sqlite3_column_type(stmt, colIndex);
        colName = sqlite3_column_name(stmt, colIndex);
        
        NSString* strColName = [NSString stringWithUTF8String:colName];
        
        propertyInfo = [propertyInfoDict objectForKey:strColName];
        if(propertyInfo == nil)
        {
            continue;
        }
        
        if(colType == SQLITE_TEXT)
        {
            //NSString* strVal = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, colIndex)];
            NSString* strVal = [self fetchTextValueOfColIndex:colIndex stmt:stmt];
            [self setDataProperty:data propertyInfo:propertyInfo stringValue:strVal];
            
            strVal = nil;
        }
        else if(colType == SQLITE_INTEGER)
        {
            long long longVal = sqlite3_column_int64(stmt, colIndex);
            [self setDataProperty:data propertyInfo:propertyInfo longlongValue:longVal];
        }
        else if(colType == SQLITE_FLOAT)
        {
            double doubleVal = sqlite3_column_double(stmt, colIndex);
            [self setDataProperty:data propertyInfo:propertyInfo doubleValue:doubleVal];
        }
        
        propertyInfo = nil;
        strColName = nil;
    }
    
    return data;
}

-(void)fetchRowIntoXml:(NSMutableString*)xml stmt:(sqlite3_stmt*)stmt colCount:(int)colCount nodeName:(NSString*)nodeName
{
    const char* colName;
    int colType = 0;
    
    [xml appendFormat:SQLITE_UTIL_TAG_NAME_BEGIN_FORMAT, nodeName];
    
    for(int colIndex = 0; colIndex < colCount; colIndex++)
    {
        colType = sqlite3_column_type(stmt, colIndex);
        colName = sqlite3_column_name(stmt, colIndex);
        
        NSString* strColName = [NSString stringWithUTF8String:colName];
        
        if(colType == SQLITE_TEXT)
        {
            //NSString* strVal = [NSString stringWithUTF8String:(const char*)sqlite3_column_text(stmt, colIndex)];
            NSString* strVal = [self fetchTextValueOfColIndex:colIndex stmt:stmt];
            [xml appendFormat:SQLITE_UTIL_TAG_NAME_FORMAT_STRING, strColName, [XmlContentEncoder stringByEncodeXmlSpecialChars:strVal], strColName];
            strVal = nil;
        }
        else if(colType == SQLITE_INTEGER)
        {
            long long longVal = sqlite3_column_int64(stmt, colIndex);
            [xml appendFormat:SQLITE_UTIL_TAG_NAME_FORMAT_LONG, strColName, longVal, strColName];
        }
        else if(colType == SQLITE_FLOAT)
        {
            double doubleVal = sqlite3_column_double(stmt, colIndex);
            [xml appendFormat:SQLITE_UTIL_TAG_NAME_FORMAT_DOUBLE, strColName, doubleVal, strColName];
        }
        
        strColName = nil;
    }
    
    [xml appendFormat:SQLITE_UTIL_TAG_NAME_END_FORMAT, nodeName];    
}


-(void)handleError:(int)errorCode operation:(NSString*)operation
{
    if(errorCode != SQLITE_OK)
    {
        //@throw [SqliteException exceptionWithErrorCode:errorCode operation:operation];
        NSLog(@"SqliteUtil errorCode:%d operation:%@", errorCode, operation);
    }
}

-(void)handleErrorWithErrorMsg:(int)errorCode operation:(NSString*)operation
{
    if(errorCode != SQLITE_OK)
    {
        if(_errorMsg != NULL)
        {
            SSLogError(@"SQLite error:%s", _errorMsg);

            sqlite3_free(_errorMsg);
            _errorMsg = NULL;
        }
        
        //@throw [SqliteException exceptionWithErrorCode:errorCode operation:operation];
        NSLog(@"SqliteUtil errorCode:%d operation:%@", errorCode, operation);
    }
    else
    {
        if(_errorMsg != NULL)
        {
            sqlite3_free(_errorMsg);
            _errorMsg = NULL;
        }
    }
}

-(NSString*)fetchTextValueOfColIndex:(int)colIndex stmt:(sqlite3_stmt*)stmt
{
    const char* cVal = (const char*)sqlite3_column_text(stmt, colIndex);
    //if(cVal == NULL || (strcmp(cVal, "(null)") == 0))
    if(cVal == NULL)
    {
        return @"";
    }
    else 
    {
        return [NSString stringWithUTF8String:cVal];
    }
}
        
@end
