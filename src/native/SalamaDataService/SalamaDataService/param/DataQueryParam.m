//
//  DataQueryParam.m
//  CodeInHand
//
//  Created by XingGu Liu on 12-9-24.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "DataQueryParam.h"

@implementation DataQueryParam

@synthesize webService;

@synthesize localStorage;

@synthesize localQuery;

- (id)copyWithZone:(NSZone *)zone
{
    DataQueryParam* copy = [[DataQueryParam allocWithZone:zone] init];
    
    if(self.webService != nil)
    {
        copy.webService = [self.webService copy];
    }
    
    if(self.localStorage != nil)
    {
        copy.localStorage = [self.localStorage copy];
    }
    
    if(self.localQuery != nil)
    {
        copy.localQuery = [self.localQuery copy];
    }
    
    return copy;
}

@end
