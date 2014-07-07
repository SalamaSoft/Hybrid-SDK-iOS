//
//  SalamaUserService.m
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-26.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaUserService.h"

#import "SalamaAppService.h"
#import "SalamaWebServiceUtil.h"
#import "TimeUtil.h"
#import "MD5Util.h"
#import "ASIHTTPUtil.h"

@implementation UserAuthInfo

@synthesize loginId;
@synthesize returnCode;

@synthesize userId;
@synthesize authTicket;
@synthesize expiringTime;

@end


@interface SalamaUserService()

- (UserAuthInfo*)getStoredUserAuthInfo;

@end

#define EASY_APP_USER_AUTH_SERVICE @"com.salama.easyapp.service.UserAuthService"
#define USER_INFO_STORED_KEY @"currentSalamaUser"

@implementation SalamaUserService

@synthesize userAuthInfo = _userAuthInfo;

static SalamaUserService* _singleton;

+ (SalamaUserService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaUserService alloc] init];
    });
    
    return _singleton;
}

- (id)init
{
    if(self = [super init])
    {
        _userAuthInfo = [self getStoredUserAuthInfo];
        if(_userAuthInfo == nil)
        {
            _userAuthInfo = [[UserAuthInfo alloc] init];
        }
    }
    
    return self;
}

- (int)isUserAuthValid
{
    if(_userAuthInfo == nil || _userAuthInfo.authTicket == nil || _userAuthInfo.authTicket.length == 0)
    {
        return 0;
    }
    else
    {
        if(_userAuthInfo.expiringTime <= [TimeUtil getCurrentTime])
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
}

- (UserAuthInfo *)getUserAuthInfo
{
    return _userAuthInfo;
}

- (UserAuthInfo*)getStoredUserAuthInfo
{
    NSString* dataXml = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO_STORED_KEY];
    SSLogDebug(@"userAuthInfoXml:%@", dataXml);
    if(dataXml == nil)
    {
        return nil;
    }
    else
    {
        return [SimpleMetoXML stringToObject:dataXml dataType:[UserAuthInfo class]];
    }
}

- (void)storeUserAuthInfo:(UserAuthInfo *)userAuthInfo
{
    if(userAuthInfo == nil)
    {
        [self clearUserAuthInfo];
    }
    else
    {
        _userAuthInfo.loginId = userAuthInfo.loginId;
        _userAuthInfo.returnCode = userAuthInfo.returnCode;
        _userAuthInfo.userId = userAuthInfo.userId;
        _userAuthInfo.authTicket = userAuthInfo.authTicket;
        _userAuthInfo.expiringTime = userAuthInfo.expiringTime;
    }

    NSString* dataXml = [SimpleMetoXML objectToString:_userAuthInfo];
    SSLogDebug(@"userAuthInfoXml:%@", dataXml);
    [[NSUserDefaults standardUserDefaults] setObject:dataXml forKey:USER_INFO_STORED_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearUserAuthInfo
{
    //_userAuthInfo.loginId = @"";
    _userAuthInfo.returnCode = @"";
    _userAuthInfo.userId = @"";
    _userAuthInfo.authTicket = @"";
    _userAuthInfo.expiringTime = 0;
}

- (UserAuthInfo *)signUp:(NSString *)loginId password:(NSString *)password
{
    NSString* passwordMD5 = [MD5Util md5String:password];
    
    NSString* resultXml = [ASIHTTPUtil doGetMethodWithUrl:[SalamaAppService singleton].appServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appToken", @"loginId", @"passwordMD5", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_USER_AUTH_SERVICE, @"signUp", [[SalamaAppService singleton] getAppToken], loginId, passwordMD5, nil] encoding:NSUTF8StringEncoding timeoutSeconds:[SalamaAppService singleton].webService.requestTimeoutSeconds];
    
    UserAuthInfo* authInfo = nil;
    if(resultXml != nil && resultXml.length > 0)
    {
        authInfo = [SimpleMetoXML stringToObject:resultXml];
    }
    [self storeUserAuthInfo:authInfo];
    
    return authInfo;
}

- (UserAuthInfo *)login:(NSString *)loginId password:(NSString *)password
{
    NSString* utcTime = [NSString stringWithFormat:@"%lld", [TimeUtil getCurrentTime]];
    NSString* utcTimeMD5 = [MD5Util md5String:utcTime];
    NSString* passwordMD5 = [MD5Util md5String:password];
    NSString* passwordMD5MD5 = [MD5Util md5String:[NSString stringWithFormat:@"%@%@", passwordMD5, utcTimeMD5]];
    
    NSString* resultXml = [ASIHTTPUtil doGetMethodWithUrl:[SalamaAppService singleton].appServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appToken", @"loginId", @"passwordMD5MD5", @"utcTime", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_USER_AUTH_SERVICE, @"login", [[SalamaAppService singleton] getAppToken], loginId, passwordMD5MD5, utcTime, nil] encoding:NSUTF8StringEncoding timeoutSeconds:[SalamaAppService singleton].webService.requestTimeoutSeconds];
    
    UserAuthInfo* authInfo = nil;
    if(resultXml != nil && resultXml.length > 0)
    {
        authInfo = [SimpleMetoXML stringToObject:resultXml];
    }
    [self storeUserAuthInfo:authInfo];
    
    return authInfo;
}

- (UserAuthInfo *)loginByTicket
{
    NSString* resultXml = [ASIHTTPUtil doGetMethodWithUrl:[SalamaAppService singleton].appServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appToken", @"authTicket", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_USER_AUTH_SERVICE, @"loginByTicket", [[SalamaAppService singleton] getAppToken], _userAuthInfo.authTicket==nil?@"":_userAuthInfo.authTicket, nil] encoding:NSUTF8StringEncoding timeoutSeconds:[SalamaAppService singleton].webService.requestTimeoutSeconds];
    
    UserAuthInfo* authInfo = nil;
    if(resultXml != nil && resultXml.length > 0)
    {
        authInfo = [SimpleMetoXML stringToObject:resultXml];
    }
    [self storeUserAuthInfo:authInfo];
    
    return authInfo;
}

- (UserAuthInfo *)changePassword:(NSString *)loginId password:(NSString *)password newPassword:(NSString *)newPassword
{
    NSString* passwordMD5 = [MD5Util md5String:password];
    NSString* newPasswordMD5 = [MD5Util md5String:newPassword];
    
    NSString* resultXml = [ASIHTTPUtil doGetMethodWithUrl:[SalamaAppService singleton].appServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appToken", @"loginId", @"passwordMD5", @"newPasswordMD5", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_USER_AUTH_SERVICE, @"changePassword", [[SalamaAppService singleton] getAppToken], loginId, passwordMD5, newPasswordMD5, nil] encoding:NSUTF8StringEncoding timeoutSeconds:[SalamaAppService singleton].webService.requestTimeoutSeconds];
    
    UserAuthInfo* authInfo = nil;
    if(resultXml != nil && resultXml.length > 0)
    {
        authInfo = [SimpleMetoXML stringToObject:resultXml];
    }
    [self storeUserAuthInfo:authInfo];
    
    return authInfo;
}

- (NSString *)logout
{
    NSString* result = [ASIHTTPUtil doGetMethodWithUrl:[SalamaAppService singleton].appServiceHttpsUrl paramNames:[NSArray arrayWithObjects:@"serviceType", @"serviceMethod", @"appToken", @"authTicket", nil] paramValues:[NSArray arrayWithObjects:EASY_APP_USER_AUTH_SERVICE, @"logout", [[SalamaAppService singleton] getAppToken], _userAuthInfo.authTicket==nil?@"":_userAuthInfo.authTicket, nil] encoding:NSUTF8StringEncoding timeoutSeconds:[SalamaAppService singleton].webService.requestTimeoutSeconds];
    
    _userAuthInfo.authTicket = @"";
    _userAuthInfo.expiringTime = 0;
    [self storeUserAuthInfo:_userAuthInfo];
    
    return result;
}

@end
