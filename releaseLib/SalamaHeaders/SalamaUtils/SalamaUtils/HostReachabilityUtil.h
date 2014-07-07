//
//  HostReachabilityUtil.h
//  CodeInHands
//
//  Created by XingGu Liu on 12-9-20.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Reachability.h"

#define HOST_REACHABILITY_UTIL_HOST_TEST_INTERVAL_MILLISECOND_DEFAULT 15000
#define HOST_REACHABILITY_UTIL_HOST_TEST_TIMEOUT_MILLISECOND_DEFAULT 3000

@interface HostReachabilityUtil : NSObject
{
    @private
    Reachability* _wifiReach;
    Reachability* _internetReach;
    
    BOOL _isMobileNetAvailable;
    BOOL _isWifiAvailable;
    BOOL _isHostAvailable;
    
    NSString* _hostTestUrl;
    int _hostTestIntervalMillisecond;
    int _hostTestTimeoutMilisecond;
    
    long long _lastCheckWebEnableTime;
}

/**
 * 初始化
 * @param hostTestUrl 探测用的URL
 * @param hostTestIntervalMillisecond 探测的时间间隔(单位:毫秒)
 * @param hostTestTimeoutMilisecond 探测的超时事件(单位:毫秒)，回应超过此时间，认为hostTestUrl无响应
 **/
- (id)init:(NSString *)hostTestUrl hostTestIntervalMillisecond:(int)hostTestIntervalMillisecond hostTestTimeoutMilisecond:(int)hostTestTimeoutMilisecond;
/**
 * 是否蜂窝网络可用
 */
@property (nonatomic, readonly) BOOL isMobileNetAvailable;

/**
 * 是否WIFI网络可用
 */
@property (nonatomic, readonly) BOOL isWifiAvailable;

/**
 * 是否服务器可用
 */
@property (nonatomic, readonly) BOOL isHostAvailable;

@end
