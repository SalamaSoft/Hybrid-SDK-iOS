//
//  ResourceFileManager.m
//  
//
//  Created by XingGu Liu on 12-6-6.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "ResourceFileManager.h"

@interface ResourceFileManager(PrivateMethod)


@end

@implementation ResourceFileManager

-(id)initWithStorageDirPath:(NSString*)storageDirPath
{
    if(self = [super init])
    {
        _storageDirPath = [storageDirPath copy];
        _fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if([_fileManager fileExistsAtPath:_storageDirPath isDirectory:&isDir])
        {
            if(!isDir)
            {
                [_fileManager removeItemAtPath:_storageDirPath error:nil];
            }
        }
        else {
            [_fileManager createDirectoryAtPath:_storageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    return self;
}

-(NSString*)fileStorageDirPath
{
    return _storageDirPath;
}

-(NSString*)getResourceFilePath:(NSString*)resId
{
    return [_storageDirPath stringByAppendingPathComponent:resId];
}

-(BOOL)isResourceFileExists:(NSString*)resId
{
    BOOL isDir;
    BOOL isExists = [_fileManager fileExistsAtPath:[self getResourceFilePath:resId] isDirectory:&isDir];
    
    if(isExists && !isDir)
    {
        return YES;
    }
    else 
    {
        return NO;
    }
}

-(void)changeResId:(NSString*)resId toResId:(NSString*)toResId
{
    NSString* srcPath = [self getResourceFilePath:resId];
    NSString* toPath = [self getResourceFilePath:toResId];
    
    [_fileManager moveItemAtPath:srcPath toPath:toPath error:nil];
}

-(void)saveResourceFileWithNSData:(NSData*)data resId:(NSString*)resId
{
    [_fileManager createFileAtPath:[self getResourceFilePath:resId] contents:data attributes:nil];
}

/***** Private Method *****/

@end
