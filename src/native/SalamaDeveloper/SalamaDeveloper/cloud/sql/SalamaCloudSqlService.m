//
//  SalamaCloudSqlService.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaCloudSqlService.h"
#import "SalamaAppService.h"
#import "SalamaUserService.h"

@implementation SalamaCloudSqlService

#define EASY_APP_SQL_SERVICE @"com.salama.easyapp.service.SQLService"

static SalamaCloudSqlService* _singleton;

+ (SalamaCloudSqlService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaCloudSqlService alloc] init];
    });
    
    return _singleton;
}

- (NSString *)executeQuery:(NSString *)sql
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    NSString* result = [[SalamaAppService singleton].webService doPost:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"sql", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_SQL_SERVICE, @"executeQuery", authTicket, sql, nil]];
    
    return result;
}

- (int)executeUpdate:(NSString *)sql
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    NSString* result = [[SalamaAppService singleton].webService doPost:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"sql", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_SQL_SERVICE, @"executeUpdate", authTicket, sql, nil]];
    
    if(result == nil || result.length == 0)
    {
        return 0;
    }
    else
    {
        return [result intValue];
    }
}

- (NSString *)insertData:(NSString *)dataTable dataXml:(NSString *)dataXml aclRestrictUserRead:(NSString *)aclRestrictUserRead aclRestrictUserUpdate:(NSString *)aclRestrictUserUpdate aclRestrictUserDelete:(NSString *)aclRestrictUserDelete
{
    NSString* authTicket = @"";
    if([SalamaUserService singleton].userAuthInfo != nil && [SalamaUserService singleton].userAuthInfo.authTicket != nil)
    {
        authTicket = [SalamaUserService singleton].userAuthInfo.authTicket;
    }
    NSString* result = [[SalamaAppService singleton].webService doPost:[SalamaAppService singleton].appServiceHttpUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"authTicket", @"dataTable", @"dataXml", @"aclRestrictUserRead", @"aclRestrictUserUpdate", @"aclRestrictUserDelete", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_SQL_SERVICE, @"insertData", authTicket, dataTable, dataXml, aclRestrictUserRead==nil?@"":aclRestrictUserRead, aclRestrictUserUpdate==nil?@"":aclRestrictUserUpdate, aclRestrictUserDelete==nil?@"":aclRestrictUserDelete, nil]];
    
    return result;
}

@end
