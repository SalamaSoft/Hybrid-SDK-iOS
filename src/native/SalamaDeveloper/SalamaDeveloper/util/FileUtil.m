//
//  FileUtil.m
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+ (int)removeAllItemsAtDir:(NSString *)dirPath
{
    int fileCount = 0;
    
    NSString* file = nil;
    NSString* srcFilePath = nil;
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* filesEnum = [fileManager enumeratorAtPath:dirPath];
    
    while(file = [filesEnum nextObject])
    {
        srcFilePath = [dirPath stringByAppendingPathComponent:file];
        
        //remove
        [fileManager removeItemAtPath:srcFilePath error:nil];
        
        fileCount++;
    }
    
    fileManager = nil;
    
    return fileCount;
}

+ (int)copyFilesFromDir:(NSString *)srcDirPath destDir:(NSString *)destDirPath
{
    int fileCount = 0;
    
    NSString* file = nil;
    NSString* srcFilePath = nil;
    NSString* destFilePath = nil;
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator* filesEnum = [fileManager enumeratorAtPath:srcDirPath];
    
    while(file = [filesEnum nextObject])
    {
        srcFilePath = [srcDirPath stringByAppendingPathComponent:file];
        destFilePath = [destDirPath stringByAppendingPathComponent:file];
        
        //copy
        [fileManager copyItemAtPath:srcFilePath toPath:destFilePath error:nil];
        
        fileCount++;
    }
    
    fileManager = nil;
    
    return fileCount;
}

@end
