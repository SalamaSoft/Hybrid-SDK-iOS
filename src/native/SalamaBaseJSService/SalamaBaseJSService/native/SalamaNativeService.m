//
//  SalamaNativeService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaNativeService.h"

@implementation SalamaNativeService

@synthesize fileService = _fileService;
@synthesize sqlService = _sqlService;

- (FileService *)fileService
{
    return _fileService;
}

- (SqlService *)sqlService
{
    return _sqlService;
}

- (id)initWithDataService:(SalamaDataService *)dataService
{
    if(self = [super init])
    {
        _fileService = [[FileService alloc] init];
        _sqlService = [[SqlService alloc] initWithDataService:dataService];
    }
    
    return self;
}

@end
