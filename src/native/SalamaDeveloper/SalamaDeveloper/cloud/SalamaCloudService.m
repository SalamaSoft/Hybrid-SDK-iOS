//
//  SalamaCloudService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaCloudService.h"

@implementation SalamaCloudService

@synthesize fileService;
@synthesize sqlService;

- (SalamaCloudFileService *)fileService
{
    return [SalamaCloudFileService singleton];
}

- (SalamaCloudSqlService *)sqlService
{
    return [SalamaCloudSqlService singleton];
}

static SalamaCloudService* _singleton;

+ (SalamaCloudService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaCloudService alloc] init];
    });
    
    return _singleton;
}

@end
