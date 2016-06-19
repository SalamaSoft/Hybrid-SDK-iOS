//
//  DefaultDBManager.m
//  SalamaDataCore
//
//  Created by XingGu Liu on 12-9-3.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "DBManager.h"

#import "sys/xattr.h"

@interface DBManager (PrivateMethod)

+ (BOOL)checkDbDir:(NSString*)dbDirPath;

+ (BOOL)setSkipBackupAttributeToFilePath:(NSString *)filePath;

@end

@implementation DBManager

+ (BOOL)setSkipBackupAttributeToFilePath:(NSString *)filePath
{
    u_int8_t attrValue = 1;
    
    int result = setxattr([filePath UTF8String], "com.apple.MobileBackup", &attrValue, sizeof(attrValue), 0, 0);
    
    return (result == 0);
}

+ (NSString*)defaultDbDirPath:(LocalDBLocationType)localDBLocationType
{
    NSArray* specialPaths;
    NSString* dbBaseDirPath;
    if(localDBLocationType == LocalDBLocationTypeDocuments)
    {
        specialPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        dbBaseDirPath = [specialPaths objectAtIndex:0];
    }
    else if(localDBLocationType == LocalDBLocationTypeLibraryCache)
    {
        specialPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        dbBaseDirPath = [specialPaths objectAtIndex:0];
    }
    
    specialPaths = nil;

    NSString* dbDirPath = [dbBaseDirPath stringByAppendingPathComponent:@"SalamaData"];
    
    dbBaseDirPath = nil;
    
    return dbDirPath;
}

- (id)initWithDbName:(NSString *)dbName dbDirPath:(NSString *)dbDirPath
{
    self = [super init];
    
    if(self)
    {
        //check db dir and mkdir if it does not exist
        if(![DBManager checkDbDir:dbDirPath])
        {
            [DBManager setSkipBackupAttributeToFilePath:dbDirPath];
        }
        if((dbName != nil) && (dbDirPath != nil))
        {
            //init dbFilePath
            _dbFilePath = [dbDirPath stringByAppendingPathComponent:dbName];
        }
    }
    
    return self;
}

- (DBDataUtil *)createNewDBDataUtil
{
    SqliteUtil* newSqliteUtil = [[SqliteUtil alloc] init:_dbFilePath];
    [newSqliteUtil open];
    
    DBDataUtil* newDbDataUtil = [[DBDataUtil alloc] init:newSqliteUtil];
    
    return newDbDataUtil;
}


+(BOOL)checkDbDir:(NSString*)dbDirPath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    BOOL isDir;
    BOOL isDirExists = YES;
    
    //check if target dir exists    
    if([fm fileExistsAtPath:dbDirPath isDirectory:&isDir])
    {
        if(!isDir)
        {
            //dir exists but not dir, then delete it
            [fm removeItemAtPath:dbDirPath error:nil];
            
            [fm createDirectoryAtPath:dbDirPath withIntermediateDirectories:NO attributes:nil error:nil];
            
            isDirExists = NO;
        }
    }
    else
    {
        [fm createDirectoryAtPath:dbDirPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        isDirExists = NO;
    }
    
    fm = nil;
    
    return isDirExists;
}

@end
