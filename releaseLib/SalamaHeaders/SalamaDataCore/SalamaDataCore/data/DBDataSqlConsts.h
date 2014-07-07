//
//  DBDataSqlConsts.h
//  
//
//  Created by XingGu Liu on 12-8-14.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const DB_SQL_DATA_COLUMN_UPDATE_TIME = @"updateTime";

/***** DataTableSetting *****/
static NSString* const DB_SQL_FORMAT_SELECT_DATA_TABLE_SETTING = @"select * from DataTableSetting where tableName = '%@'";
static NSString* const CLOUD_DATA_SQL_FORMAT_DELETE_DATA_TABLE_SETTING = @"delete from DataTableSetting where tableName = '%@'";

/***** CREATE TABLE SQL FORMAT *****/
static NSString* const DB_SQL_FORMAT_CREATE_TABLE_SET_TABLE_NAME = @"create table %@ ("; 
static NSString* const DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_TEXT = @" %@ TEXT,"; 
static NSString* const DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_INTEGER = @" %@ INTEGER,"; 
static NSString* const DB_SQL_FORMAT_CREATE_TABLE_SET_COLUMN_REAL = @" %@ REAL,"; 
static NSString* const DB_SQL_FORMAT_CREATE_TABLE_SET_PRIMARY_KEY = @" primary key(%@)"; 
static NSString* const DB_SQL_FORMAT_CREATE_TABLE_END = @")"; 

static NSString* const DB_SQL_FORMAT_CLOUD_DATA_BASE_COLUMNS = @" dataId TEXT,createUserId Text, createTime INTEGER, updateUserId TEXT, shareType INTEGER, delFlg INTEGER,";

static NSString* const DB_SQL_FORMAT_USER_DATA_BASE_COLUMNS = @" userId TEXT,";

static NSString* const DB_SQL_FORMAT_BASE_DATA_BASE_COLUMNS = @" updateTime INTEGER,";

/***** DELETE SQL FORMAT *****/
static NSString* const DB_SQL_FORMAT_DELETE_FROM_DATA_TABLE_SETTING_BY_TABLE_NAME = @"delete from DataTableSetting where tableName = '%@'";

/***** INSERT SQL FORMAT *****/
static NSString* const DB_SQL_FORMAT_INSERT_SET_TABLE = @"insert into %@ ("; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN_0 = @" %@ "; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN = @" ,%@ "; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_STRING = @" '%@' "; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_NUMBER = @" %@ "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_LONG = @" %lld "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_INSERT_SET_COLUMN_0_VALUE_DOUBLE = @" %Lf "; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_STRING = @",'%@' "; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_NUMBER = @",%@ "; 
//NSString* const CLOUD_DATA_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_LONG = @",%lld "; 
//NSString* const CLOUD_DATA_SQL_FORMAT_INSERT_SET_COLUMN_VALUE_DOUBLE = @",%Lf "; 
static NSString* const DB_SQL_FORMAT_INSERT_SET_COLUMN_END = @") values (";
static NSString* const DB_SQL_FORMAT_INSERT_END = @")"; 

/***** SQL Where condition format *****/
static NSString* const DB_SQL_FORMAT_WHERE = @" where ";
static NSString* const DB_SQL_FORMAT_CONDITION_VALUE_STRING = @" %@ = '%@' "; 
static NSString* const DB_SQL_FORMAT_CONDITION_VALUE_NUMBER = @" %@ = %@ "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_CONDITION_VALUE_LONG = @" %@ = %lld "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_CONDITION_VALUE_DOUBLE = @" %@ = %Lf "; 
static NSString* const DB_SQL_FORMAT_AND_CONDITION_VALUE_STRING = @"and %@ = '%@' "; 
static NSString* const DB_SQL_FORMAT_AND_CONDITION_VALUE_NUMBER = @"and %@ = %@ "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_AND_CONDITION_VALUE_LONG = @"and %@ = %lld "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_AND_CONDITION_VALUE_DOUBLE = @"and %@ = %Lf "; 

/***** SELECT * SQL format *****/
static NSString* const DB_SQL_FORMAT_SELECT_SET_TABLE = @"select * from %@"; 

/***** UPDATE SQL FORMAT *****/
static NSString* const DB_SQL_FORMAT_UPDATE_SET_TABLE = @"update %@ set "; 
static NSString* const DB_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_STRING = @" %@ = '%@' "; 
static NSString* const DB_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_NUMBER = @" %@ = %@ "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_LONG = @" %@ = %lld "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_UPDATE_SET_COLUMN_0_VALUE_DOUBLE = @" %@ = %Lf "; 
static NSString* const DB_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_STRING = @",%@ = '%@' "; 
static NSString* const DB_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_NUMBER = @",%@ = %@ "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_LONG = @",%@ = %lld "; 
//static NSString* const CLOUD_DATA_SQL_FORMAT_UPDATE_SET_COLUMN_VALUE_DOUBLE = @", %@ = %Lf "; 

static NSString* const DB_SQL_FORMAT_DELETE_SET_TABLE = @"delete from %@ "; 
