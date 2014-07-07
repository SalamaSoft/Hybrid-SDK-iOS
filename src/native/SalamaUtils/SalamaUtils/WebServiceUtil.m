//
//  WebService.m
//  CodeInHands
//
//  Created by XingGu Liu on 12-9-20.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "WebServiceUtil.h"

#define HTTP_STATUS_CODE_SUCCESS 200

@interface WebServiceUtil()

@end

@implementation WebServiceUtil

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
    if(paramNames != nil)
    {
        for(int i = 0; i < paramNames.count; i++)
        {
            if(i < paramValues.count)
            {
                [httpMethod addParameter:[paramValues objectAtIndex:i] withName:[paramNames objectAtIndex:i]];
            }
        }
    }
    
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
    int i;
    if(paramNames != nil)
    {
        for(i = 0; i < paramNames.count; i++)
        {
            if(i < paramValues.count)
            {
                [httpMethod addPart:[StringPart stringPartWithParameter:[paramValues objectAtIndex:i] withName:[paramNames objectAtIndex:i]]];
            }
        }
    }
    
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
    else 
    {
        return nil;
    }
}


@end
