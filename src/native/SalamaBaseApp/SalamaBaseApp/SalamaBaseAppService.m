//
//  SalamaBaseAppService.m
//  SalamaBaseApp
//
//  Created by XingGu Liu on 16/6/16.
//  Copyright © 2016年 Salama Soft. All rights reserved.
//

#import "SalamaBaseAppService.h"
#import "OpenUDID.h"

@implementation SalamaBaseAppService

static int _httpRequestTimeoutSeconds = DEFAULT_HTTP_REQUEST_TIMEOUT_SECONDS;

static SalamaBaseAppService* _singleton;

+ (SalamaBaseAppService*)singleton
{
    static dispatch_once_t createSingleton;
    dispatch_once(&createSingleton, ^{
        _singleton = [[SalamaBaseAppService alloc] init];
    });
    
    return _singleton;
}

+ (void)setHttpRequestTimeOutSeconds:(int)httpRequestTimeOutSeconds
{
    _httpRequestTimeoutSeconds = httpRequestTimeOutSeconds;
}

- (id)init
{
    self = [super initWithUdid:[OpenUDID value] httpRequestTimeoutSeconds:_httpRequestTimeoutSeconds webPackageDirName:DEFAULT_WEB_PACKAGE_DIR webResourceDirName:DEFAULT_WEB_RESOURCE_DIR];
    if(self)
    {
        [[WebManager webController].nativeService registerService:SALAMA_SERVICE_NAME service:self];
    }
    
    return self;
}

@end
