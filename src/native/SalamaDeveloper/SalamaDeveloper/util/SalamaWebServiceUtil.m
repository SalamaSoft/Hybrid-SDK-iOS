//
//  SalamaWebServiceUtil.m
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-26.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "SalamaWebServiceUtil.h"
#import "HttpClient.h"
#import "SalamaAppService.h"

#define HTTP_STATUS_CODE_SUCCESS 200

//Salama Easy App在AppToken认证不通过的时候，采用code 405来表征
#define HTTP_STATUS_CODE_APP_TOKEN_INVALID 405
#define PARAM_NAME_BUNDLE_ID @"bundleId"
#define PARAM_NAME_APP_TOKEN @"appToken"
#define PARAM_NAME_AUTH_TICKET @"authTicket"

@implementation SalamaWebServiceUtil

+(id) doBasicMethod:(NSString*)url isDownload:(BOOL)isDownload isPostMethod:(BOOL)isPostMethod paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues requestTimeoutInterval:(int)requestTimeoutInterval
{
    BasicMethod* httpMethod;
    
    if(isPostMethod)
    {
        httpMethod = [[PostMethod alloc] init];
    }
    else
    {
        httpMethod = [[GetMethod alloc] init];
    }
    
    if(requestTimeoutInterval > 0)
    {
        httpMethod.requestTimeoutInterval = requestTimeoutInterval;
    }
    
    //String Parameters
    BOOL isAppTokenAdded = NO;
    BOOL isAuthTicketAdded = NO;
    NSString* authTicket = @"";
    if([[SalamaUserService singleton] getUserAuthInfo].authTicket != nil)
    {
        authTicket = [[SalamaUserService singleton] getUserAuthInfo].authTicket;
    }
    
    if(paramNames != nil)
    {
        for(int i = 0; i < paramNames.count; i++)
        {
            if(i < paramValues.count)
            {
                if([PARAM_NAME_APP_TOKEN isEqualToString:[paramNames objectAtIndex:i]])
                {
                    [httpMethod addParameter:[[SalamaAppService singleton] getAppToken] withName:[paramNames objectAtIndex:i]];
                    isAppTokenAdded = YES;
                }
                else if ([PARAM_NAME_AUTH_TICKET isEqualToString:[paramNames objectAtIndex:i]])
                {
                    [httpMethod addParameter:authTicket withName:[paramNames objectAtIndex:i]];
                    isAuthTicketAdded = YES;
                }
                else
                {
                    [httpMethod addParameter:[paramValues objectAtIndex:i] withName:[paramNames objectAtIndex:i]];
                }
            }
        }
    }

    if(!isAppTokenAdded)
    {
        [httpMethod addParameter:[[SalamaAppService singleton] getAppToken] withName:PARAM_NAME_APP_TOKEN];
    }
    if(!isAuthTicketAdded)
    {
        [httpMethod addParameter:authTicket withName:authTicket];
    }
    
    [httpMethod addParameter:[SalamaAppService singleton].bundleId withName:PARAM_NAME_BUNDLE_ID];
    
    //URL
    NSURL* destURL = [NSURL URLWithString:url];
    
    HttpResponse* response;
    if(isPostMethod)
    {
        response = [(PostMethod*)httpMethod executeSynchronouslyAtURL:destURL];
    }
    else {
        response = [(GetMethod*)httpMethod executeSynchronouslyAtURL:destURL];
    }
    
    //Response
    if(response.statusCode == HTTP_STATUS_CODE_SUCCESS)
    {
        if(isDownload)
        {
            return response.responseData;
        }
        else
        {
            return response.responseString;
        }
    }
    else if(response.statusCode == HTTP_STATUS_CODE_APP_TOKEN_INVALID)
    {
        [[SalamaAppService singleton] appLogin];
        
        return nil;
    }
    else
    {
        return nil;
    }
}

+(id) doMultipartMethod:(NSString*)url isDownload:(BOOL)isDownload paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues filePartValues:(NSArray*)filePartValues requestTimeoutInterval:(int)requestTimeoutInterval
{
    MultipartMethod* httpMethod = [[MultipartMethod alloc] init];
    
    if(requestTimeoutInterval > 0)
    {
        httpMethod.requestTimeoutInterval = requestTimeoutInterval;
    }
    
    //String Parameters
    BOOL isAppTokenAdded = NO;
    BOOL isAuthTicketAdded = NO;
    NSString* authTicket = @"";
    if([[SalamaUserService singleton] getUserAuthInfo].authTicket != nil)
    {
        authTicket = [[SalamaUserService singleton] getUserAuthInfo].authTicket;
    }

    int i;
    if(paramNames != nil)
    {
        for(i = 0; i < paramNames.count; i++)
        {
            if(i < paramValues.count)
            {
                if([PARAM_NAME_APP_TOKEN isEqualToString:[paramNames objectAtIndex:i]])
                {
                    [httpMethod addPart:[StringPart stringPartWithParameter:[[SalamaAppService singleton] getAppToken] withName:[paramNames objectAtIndex:i]]];
                    isAppTokenAdded = YES;
                }
                else if ([PARAM_NAME_AUTH_TICKET isEqualToString:[paramNames objectAtIndex:i]])
                {
                    [httpMethod addPart:[StringPart stringPartWithParameter:authTicket withName:[paramNames objectAtIndex:i]]];
                    isAuthTicketAdded = YES;
                }
                else
                {
                    [httpMethod addPart:[StringPart stringPartWithParameter:[paramValues objectAtIndex:i] withName:[paramNames objectAtIndex:i]]];
                }
            }
        }
    }
    
    if(!isAppTokenAdded)
    {
        [httpMethod addPart:[StringPart stringPartWithParameter:[[SalamaAppService singleton] getAppToken] withName:PARAM_NAME_APP_TOKEN]];
    }
    if(!isAuthTicketAdded)
    {
        [httpMethod addPart:[StringPart stringPartWithParameter:authTicket withName:PARAM_NAME_AUTH_TICKET]];
    }
    
    [httpMethod addPart:[StringPart stringPartWithParameter:[SalamaAppService singleton].bundleId withName:PARAM_NAME_BUNDLE_ID]];
    
    if(filePartValues != nil)
    {
        for(i = 0; i < filePartValues.count; i++)
        {
            [httpMethod addPart:[filePartValues objectAtIndex:i]];
        }
    }
    
    //URL
    NSURL* destURL = [NSURL URLWithString:url];
    HttpResponse* response = [httpMethod executeSynchronouslyAtURL:destURL];
    
    //Response
    if(response.statusCode == HTTP_STATUS_CODE_SUCCESS)
    {
        if(isDownload)
        {
            return response.responseData;
        }
        else
        {
            return response.responseString;
        }
    }
    else if(response.statusCode == HTTP_STATUS_CODE_APP_TOKEN_INVALID)
    {
        [[SalamaAppService singleton] appLogin];
        
        return nil;
    }
    else
    {
        return nil;
    }
}

@end
