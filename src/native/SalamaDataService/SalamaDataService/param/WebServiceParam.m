//
//  WebServiceParam.m
//  SalamaDataService
//
//  Created by XingGu Liu on 12-9-23.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "WebServiceParam.h"

@implementation WebServiceParam

/**
 func:the function name of the class:WebService. (Invoke the doBasic when it is null or empty) 
 **/
@synthesize func;

@synthesize url;
@synthesize method;

/**
 NSArray<NSString*>
 **/
@synthesize paramNames;

/**
 NSArray<NSString*>
 **/
@synthesize paramValues;

/**
 Be used in doDownload,doUploadAndDownloadToSave.
 **/
@synthesize saveTo;


/**
 NSArray<NSString*>
 Be used in doUpload, doUploadAndDownload, doUploadAndDownloadToSave, doUploadResource, doUploadAndDownloadResource.
 **/
@synthesize multiPartNames;

/**
 NSArray<NSString*>
 Be used in doUpload, doUploadAndDownload, doUploadAndDownloadToSave, doUploadResource, doUploadAndDownloadResource.
 **/
@synthesize multiPartFilePaths;

/**
 Be used in doDownloadResource, doUploadAndDownloadResource
 **/
@synthesize saveToResId;


/**
 NSArray<NSString*>
 Be used in doUploadResource, doUploadAndDownloadResource.
 **/
@synthesize multiPartResIds;

- (id)copyWithZone:(NSZone *)zone
{
    WebServiceParam* copy = [[WebServiceParam allocWithZone:zone] init];
    
    if(self.func != nil)
    {
        copy.func = [self.func copy];
    }

    if(self.url != nil)
    {
        copy.url = [self.url copy];
    }

    if(self.method != nil)
    {
        copy.method = [self.method copy];
    }

    if(self.paramNames != nil)
    {
        copy.paramNames = [self.paramNames copy];
    }
    
    if(self.paramValues != nil)
    {
        copy.paramValues = [self.paramValues copy];
    }
    
    if(self.saveTo != nil)
    {
        copy.saveTo = [self.saveTo copy];
    }
    
    if(self.multiPartNames != nil)
    {
        copy.multiPartNames = [self.multiPartNames copy];
    }
    
    if(self.multiPartFilePaths != nil)
    {
        copy.multiPartFilePaths = [self.multiPartFilePaths copy];
    }
    
    if(self.saveToResId != nil)
    {
        copy.saveToResId = [self.saveToResId copy];
    }
    
    if(self.multiPartResIds != nil)
    {
        copy.multiPartResIds = [self.multiPartResIds copy];
    }

    return copy;
}

@end
