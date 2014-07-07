//
//  TableDesc.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "TableDesc.h"

@implementation ColDesc

@synthesize colName;
@synthesize colType;

- (id)initWithColName:(NSString *)name colType:(NSString *)type
{
    if(self = [super init])
    {
        self.colName = name;
        self.colType = type;
    }
    
    return self;
}

@end

@implementation TableDesc

@synthesize tableName;
@synthesize primaryKeys;
@synthesize colDescList;

@end
