//
//  LocalStorageParam.m
//  CodeInHand
//
//  Created by XingGu Liu on 12-9-24.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "LocalStorageParam.h"

@implementation LocalStorageParam

@synthesize tableName;

@synthesize dataClass;

/**
 NSArray<NSString*>
 **/
@synthesize extraIndexNames;

/**
 NSArray<NSString*>
 **/
@synthesize extraIndexValues;

- (id)copyWithZone:(NSZone *)zone
{
    LocalStorageParam* copy = [[LocalStorageParam allocWithZone:zone] init];
    
    if(self.tableName != nil)
    {
        copy.tableName = [self.tableName copy];
    }

    if(self.dataClass != nil)
    {
        copy.dataClass = [self.dataClass copy];
    }
    
    if(self.extraIndexNames != nil)
    {
        copy.extraIndexNames = [self.extraIndexNames copy];
    }
    
    if(self.extraIndexValues != nil)
    {
        copy.extraIndexValues = [self.extraIndexValues copy];
    }
    
    return copy;
}

@end
