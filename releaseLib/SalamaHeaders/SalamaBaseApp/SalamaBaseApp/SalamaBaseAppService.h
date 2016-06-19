//
//  SalamaBaseAppService.h
//  SalamaBaseApp
//
//  Created by XingGu Liu on 16/6/16.
//  Copyright © 2016年 Salama Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseAppService.h"

#define DEFAULT_HTTP_REQUEST_TIMEOUT_SECONDS 30
#define SALAMA_SERVICE_NAME @"salama"


@interface SalamaBaseAppService : BaseAppService

/**
 * This method should be invoked before singleton().
 */
+ (void)setHttpRequestTimeOutSeconds:(int)httpRequestTimeOutSeconds;

+ (SalamaBaseAppService*)singleton;

@end
