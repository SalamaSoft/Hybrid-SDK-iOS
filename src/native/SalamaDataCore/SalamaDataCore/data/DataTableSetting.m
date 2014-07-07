//
//  DataTableSetting.m
//  
//
//  Created by XingGu Liu on 12-5-8.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "DataTableSetting.h"

/*
 These consts are for tableType in DataTableSetting
 */
int const DATA_TABLE_TYPE_CLOUD_DATA = 0; 
int const DATA_TABLE_TYPE_USER_DATA = 1; 
int const DATA_TABLE_TYPE_CUSTOMIZE = 2;

@implementation DataTableSetting

@synthesize tableName;

@synthesize tableType;

@synthesize primaryKeys;

@end
