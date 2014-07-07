//
//  ASIHTTPUtil.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-13.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "ASIHTTPUtil.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#define HTTP_STATUS_CODE_SUCCEED 200

@implementation MultiPartFile

@synthesize name;
@synthesize filePath;

- (id)initWithName:(NSString *)theName filePath:(NSString *)theFilePath
{
    if(self = [super init])
    {
        self.name = theName;
        self.filePath = theFilePath;
    }
    
    return self;
}

@end


@interface ASIHTTPUtil()

+ (NSURL*)createGetMethodUrl:(NSString*)host paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues encoding:(NSStringEncoding)encoding;

+ (void)preparePostRequest:(ASIFormDataRequest*)request paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartFiles:(NSArray *)multiPartFiles encoding:(NSStringEncoding)encoding;

@end

@implementation ASIHTTPUtil

+ (NSString*)doGetMethodWithUrl:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues encoding:(NSStringEncoding)encoding timeoutSeconds:(double)timeoutSeconds
{
    NSURL* getMethodUrl = [ASIHTTPUtil createGetMethodUrl:url paramNames:paramNames paramValues:paramValues encoding:encoding];

    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:getMethodUrl];
    
    if([[url lowercaseString] hasPrefix:@"https://"])
    {
        [request setValidatesSecureCertificate:NO];
    }
    
    [request setTimeOutSeconds:timeoutSeconds];
    [request startSynchronous];
    
    int statusCode = [request responseStatusCode];
    
    if(statusCode == HTTP_STATUS_CODE_SUCCEED)
    {
        return request.responseString;
    }
    else
    {
        return nil;
    }
}

+ (BOOL)doGetMethodDownloadWithUrl:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues encoding:(NSStringEncoding)encoding downloadToPath:(NSString *)downloadToPath timeoutSeconds:(double)timeoutSeconds
{
    NSURL* getMethodUrl = [ASIHTTPUtil createGetMethodUrl:url paramNames:paramNames paramValues:paramValues encoding:encoding];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:getMethodUrl];
    
    if([[url lowercaseString] hasPrefix:@"https://"])
    {
        [request setValidatesSecureCertificate:NO];
    }
    
    [request setTimeOutSeconds:timeoutSeconds];
    [request setDownloadDestinationPath:downloadToPath];
    [request startSynchronous];
    
    int statusCode = [request responseStatusCode];
    
    return ((statusCode == HTTP_STATUS_CODE_SUCCEED) && ([[NSFileManager defaultManager] fileExistsAtPath:downloadToPath]));
}

+ (BOOL)doGetMethodDownloadWithEncodedUrl:(NSString *)url downloadToPath:(NSString *)downloadToPath timeoutSeconds:(double)timeoutSeconds
{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    if([[url lowercaseString] hasPrefix:@"https://"])
    {
        [request setValidatesSecureCertificate:NO];
    }
    
    [request setTimeOutSeconds:timeoutSeconds];
    [request setDownloadDestinationPath:downloadToPath];
    [request startSynchronous];
    
    int statusCode = [request responseStatusCode];
    
    return ((statusCode == HTTP_STATUS_CODE_SUCCEED) && ([[NSFileManager defaultManager] fileExistsAtPath:downloadToPath]));
}

+ (NSString*)doPostMethodWithUrl:(NSString*)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartFiles:(NSArray*)multiPartFiles encoding:(NSStringEncoding)encoding timeoutSeconds:(double)timeoutSeconds
{
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    
    if([[url lowercaseString] hasPrefix:@"https://"])
    {
        [request setValidatesSecureCertificate:NO];
    }
    
    [request setTimeOutSeconds:timeoutSeconds];
    [request setStringEncoding:encoding];
    
    [self preparePostRequest:request paramNames:paramNames paramValues:paramValues multiPartFiles:multiPartFiles encoding:encoding];
        
    [request startSynchronous];
    
    int statusCode = [request responseStatusCode];
    if(statusCode == HTTP_STATUS_CODE_SUCCEED)
    {
        return request.responseString;
    }
    else
    {
        return nil;
    }
}

+ (BOOL)doPostMethodDownloadWithUrl:(NSString *)url paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartFiles:(NSArray *)multiPartFiles encoding:(NSStringEncoding)encoding downloadToPath:(NSString *)downloadToPath timeoutSeconds:(double)timeoutSeconds
{
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    
    if([[url lowercaseString] hasPrefix:@"https://"])
    {
        [request setValidatesSecureCertificate:NO];
    }

    [request setTimeOutSeconds:timeoutSeconds];
    [request setStringEncoding:encoding];
    
    [self preparePostRequest:request paramNames:paramNames paramValues:paramValues multiPartFiles:multiPartFiles encoding:encoding];
    
    [request setDownloadDestinationPath:downloadToPath];
    
    [request startSynchronous];
    
    if([request responseStatusCode] == HTTP_STATUS_CODE_SUCCEED && [[NSFileManager defaultManager] fileExistsAtPath:downloadToPath])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSURL *)createGetMethodUrl:(NSString *)host paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues encoding:(NSStringEncoding)encoding
{
    NSMutableString * newURLString = [[NSMutableString alloc] initWithString:host];
    
    if(paramNames != nil && paramNames.count > 0)
    {
        NSMutableData * body = [[NSMutableData alloc] init];
        //Loop over all the items in the parameters dictionary and add them to the body
        for(int i = 0; i < paramNames.count; i++)
        {
            if(i > 0)
            {
                [body appendData:[@"&" dataUsingEncoding:encoding]];
            }
            
            //Add the parameter
            [body appendData:[[NSString stringWithFormat:@"%@=%@", [paramNames objectAtIndex:i], [paramValues objectAtIndex:i]] dataUsingEncoding:encoding]];
        }
        
        //Convert the body data into a string
        NSString * bodyString = [[NSString alloc] initWithData:body encoding:encoding];
        
        //Append the body data as a URL query
        [newURLString appendFormat:@"?%@", bodyString];
        
        bodyString = nil;
        body = nil;
    }
    
    //Create a new URL, escaping characters as necessary
    NSURL * newURL = [NSURL URLWithString:[newURLString stringByAddingPercentEscapesUsingEncoding:encoding]];
    newURLString = nil;
    
    return newURL;
    
}

+ (void)preparePostRequest:(ASIFormDataRequest *)request paramNames:(NSArray *)paramNames paramValues:(NSArray *)paramValues multiPartFiles:(NSArray *)multiPartFiles encoding:(NSStringEncoding)encoding
{
    if(paramNames != nil)
    {
        for(int i = 0; i < paramNames.count; i++)
        {
            [request setPostValue:[paramValues objectAtIndex:i] forKey:[paramNames objectAtIndex:i]];
        }
    }
    
    if(multiPartFiles != nil)
    {
        MultiPartFile* multiPartFile = nil;
        
        for(int i = 0; i < multiPartFiles.count; i++)
        {
            multiPartFile = [multiPartFiles objectAtIndex:i];
            [request setFile:multiPartFile.filePath forKey:multiPartFile.name];
        }
    }
}


@end
