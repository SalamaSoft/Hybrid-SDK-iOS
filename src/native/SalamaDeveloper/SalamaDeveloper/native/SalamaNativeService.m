//
//  SalamaNativeService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaNativeService.h"

@implementation SalamaNativeService

@synthesize fileService;

@synthesize sqlService;

- (FileService *)fileService
{
    return [FileService singleton];
}

- (SqlService *)sqlService
{
    return [SqlService singleton];
}

static SalamaNativeService* _singleton;

+ (SalamaNativeService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaNativeService alloc] init];
    });
    
    return _singleton;
}

@end
