//
//  FileService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-3.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "FileService.h"
#import "ZipArchive.h"
#import "WebManager.h"

@interface FileService()

- (void)listFilesRecursivelyInDir:(NSString *)dirPath fileList:(NSMutableArray*)fileList;

@end

@implementation FileService

- (NSString *)getRealPathByVirtualPath:(NSString *)virtualPath
{
    return [[WebManager webController] toRealPath:virtualPath];
}

- (int)isExistsFile:(NSString *)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return 1;
    }
    else
    {
        return 0;
    }
    
}

- (int)isExistsDir:(NSString *)dirPath
{
    BOOL isDir;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if(isExists && isDir)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (NSString *)getTempDirPath
{
    return [WebManager webController].tempPath;
}

- (NSString*)copyFileFrom:(NSString *)from to:(NSString *)to
{
    if([[NSFileManager defaultManager] fileExistsAtPath:to])
    {
        [[NSFileManager defaultManager] removeItemAtPath:to error:nil];
    }
    
    [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:nil];
    
    return to;
}

- (NSString *)moveFileFrom:(NSString *)from to:(NSString *)to
{
    if([[NSFileManager defaultManager] fileExistsAtPath:to])
    {
        [[NSFileManager defaultManager] removeItemAtPath:to error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:nil];
    
    return to;
}

- (NSString *)readAllText:(NSString *)filePath
{
    [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:nil];
    
    return filePath;
}

- (NSString *)writeTextToFile:(NSString *)filePath text:(NSString *)text
{
    [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return filePath;
}

- (NSString *)appendTextToFile:(NSString *)filePath text:(NSString *)text
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSFileHandle* handle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        
        @try {
            [handle seekToEndOfFile];
            [handle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        }
        @finally {
            [handle closeFile];
        }
    }
    else
    {
        [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    return filePath;
}

- (long long)calculateVolumeOfDir:(NSString *)dirPath
{
    unsigned long long totalVolumn = 0;

    NSDirectoryEnumerator* filesEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSString* file = nil;
    NSString* filePath = nil;
    NSDictionary* attrDict = nil;
    NSNumber* vol = nil;
    BOOL isDir;
    while(file = [filesEnum nextObject])
    {
        filePath = [dirPath stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        
        if(isDir)
        {
            //dir
            totalVolumn += [self calculateVolumeOfDir:filePath];
        }
        else
        {
            attrDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            vol = [attrDict valueForKey:NSFileSize];
            totalVolumn += [vol unsignedLongLongValue];
        }
    }
    
    return totalVolumn;
}

- (NSArray *)listFileNamesInDir:(NSString *)dirPath isIncludeSubDir:(int)isIncludeSubDir
{
    NSMutableArray* fileList = [[NSMutableArray alloc] init];
    
    NSDirectoryEnumerator* filesEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSString* file = nil;
    NSString* filePath = nil;
    BOOL isDir;
    while(file = [filesEnum nextObject])
    {
        filePath = [dirPath stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        
        if(isDir)
        {
            if(isIncludeSubDir)
            {
                [fileList addObject:file];
            }
        }
        else
        {
            [fileList addObject:file];
        }
    }
    
    return fileList;
}

- (NSArray *)listFilesInDir:(NSString *)dirPath isIncludeSubDir:(int)isIncludeSubDir
{
    NSMutableArray* fileList = [[NSMutableArray alloc] init];
    
    NSDirectoryEnumerator* filesEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSString* file = nil;
    NSString* filePath = nil;
    BOOL isDir;
    while(file = [filesEnum nextObject])
    {
        filePath = [dirPath stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        
        if(isDir)
        {
            if(isIncludeSubDir)
            {
                [fileList addObject:filePath];
            }
        }
        else
        {
            [fileList addObject:filePath];
        }
    }
    
    return fileList;
}

- (NSArray *)listFilesRecursivelyInDir:(NSString *)dirPath
{
    NSMutableArray* fileList = [[NSMutableArray alloc] init];
    
    [self listFilesRecursivelyInDir:dirPath fileList:fileList];
    
    return fileList;
}

- (void)listFilesRecursivelyInDir:(NSString *)dirPath fileList:(NSMutableArray*)fileList
{
    NSDirectoryEnumerator* filesEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSString* file = nil;
    NSString* filePath = nil;
    BOOL isDir;
    while(file = [filesEnum nextObject])
    {
        filePath = [dirPath stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        
        if(isDir)
        {
            [fileList addObject:filePath];
            
            [self listFilesRecursivelyInDir:filePath fileList:fileList];
        }
        else
        {
            [fileList addObject:filePath];
        }
    }
}

- (NSString *)deleteFile:(NSString *)filePath
{
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    return filePath;
}

- (NSString *)deleteDir:(NSString *)dirPath
{
    NSDirectoryEnumerator* filesEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSString* file = nil;
    NSString* filePath = nil;
    BOOL isDir;
    while(file = [filesEnum nextObject])
    {
        filePath = [dirPath stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
        
        if(isDir)
        {
            [self deleteDir:filePath];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
    
    return dirPath;
}

- (NSString *)mkdir:(NSString *)dirPath
{
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    return dirPath;
}

- (NSString *)compressZipFromDir:(NSString *)dirPath toZipPath:(NSString *)zipPath
{
    NSArray* fileList = [self listFilesRecursivelyInDir:dirPath];

    ZipArchive* zip = [[ZipArchive alloc] init];
    
    @try {
        [zip CreateZipFile2:zipPath];

        int subDirStartIndex = dirPath.length;
        if([dirPath characterAtIndex:dirPath.length - 1] == '/')
        {
            subDirStartIndex--;
        }
        
        NSString* entryPath = nil;
        NSString* filePath = nil;
        BOOL isDir;
        
        for(int i = 0; i < fileList.count; i++)
        {
            filePath = [fileList objectAtIndex:i];
            entryPath = [filePath substringFromIndex:subDirStartIndex];
        
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
            
            if(!isDir)
            {
                [zip addFileToZip:filePath newname:entryPath];
            }
        }
        
        return zipPath;
    }
    @finally {
        [zip CloseZipFile2];
    }
}


- (NSString *)compressZipFromFile:(NSString *)filePath toZipPath:(NSString *)zipPath
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    
    @try {
        [zip CreateZipFile2:zipPath];
        
        NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
        NSString* fileName = [filePath substringFromIndex:range.location];
        
        [zip addFileToZip:filePath newname:fileName];
        
        return zipPath;
    }
    @finally {
        [zip CloseZipFile2];
    }
}

- (NSString *)decompressZip:(NSString *)zipPath toDir:(NSString *)toDir
{
    ZipArchive* zip = [[ZipArchive alloc] init];
    @try {
        if ([zip UnzipOpenFile:zipPath]) {
            [zip UnzipFileTo:toDir overWrite:YES];
        }
        
        return toDir;
    }
    @finally {
        [zip UnzipCloseFile];
    }
}
@end
