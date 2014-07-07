//
//  LocalQueryParam.m
//  SalamaDataService
//
//  Created by Liu XingGu on 12-10-5.
//
//

#import "LocalQueryParam.h"

@implementation LocalQueryParam

@synthesize sql;

@synthesize dataClass;

@synthesize resourceNames;

@synthesize resourceDownloadNotification;

- (id)copyWithZone:(NSZone *)zone
{
    LocalQueryParam* copy = [[LocalQueryParam allocWithZone:zone] init];
    
    if(self.sql != nil)
    {
        copy.sql = [self.sql copy];
    }
    
    if(self.dataClass != nil)
    {
        copy.dataClass = [self.dataClass copy];
    }
    
    if(self.resourceNames != nil)
    {
        copy.resourceNames = [self.resourceNames copy];
    }
    
    if(self.resourceDownloadNotification != nil)
    {
        copy.resourceDownloadNotification = [self.resourceDownloadNotification copy];
    }

    return copy;
}

@end
