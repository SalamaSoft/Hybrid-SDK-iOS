//
//  HostReachabilityUtil.m
//  CodeInHands
//
//  Created by XingGu Liu on 12-9-20.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "HostReachabilityUtil.h"
#import "TimeUtil.h"

#define HTTP_STATUS_CODE_SUCCESS 200

@interface HostReachabilityUtil(PrivateMethod)

- (void)initReachs;

- (void)reachabilityChanged:(NSNotification* )note;

- (void)updateNetworkStatus;

- (BOOL)testHostUrl;

@end

@implementation HostReachabilityUtil

@synthesize isMobileNetAvailable = _isMobileNetAvailable;
@synthesize isWifiAvailable = _isWifiAvailable;

- (BOOL)isHostAvailable
{
    if(_isWifiAvailable || _isMobileNetAvailable)
    {
        return [self testHostAvailable];
    }
    else
    {
        return NO;
    }
}


- (id)init
{
    self = [super init];
    if(self)
    {
        _hostTestUrl = @"www.apple.com";
        _hostTestIntervalMillisecond = HOST_REACHABILITY_UTIL_HOST_TEST_INTERVAL_MILLISECOND_DEFAULT;
        _hostTestTimeoutMilisecond = HOST_REACHABILITY_UTIL_HOST_TEST_TIMEOUT_MILLISECOND_DEFAULT;
        
        [self initReachs];
    }
    
    return self;
}

- (id)init:(NSString *)hostTestUrl hostTestIntervalMillisecond:(int)hostTestIntervalMillisecond hostTestTimeoutMilisecond:(int)hostTestTimeoutMilisecond
{
    self = [super init];
    if(self)
    {
        _hostTestUrl = [hostTestUrl copy];
        _hostTestIntervalMillisecond = hostTestIntervalMillisecond;
        _hostTestTimeoutMilisecond = hostTestTimeoutMilisecond;

        [self initReachs];
    }
    
    return self;
}


- (void)initReachs
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    _wifiReach = [Reachability reachabilityForLocalWiFi];
    [self updateNetworkStatus:_wifiReach];
	[_wifiReach startNotifier];
    
    _internetReach = [Reachability reachabilityForInternetConnection];
    [self updateNetworkStatus:_internetReach];
    [_internetReach startNotifier];
}

- (void)reachabilityChanged:(NSNotification* )note
{
    Reachability* curReach = [note object];
    
    [self updateNetworkStatus:curReach];
}

- (void)updateNetworkStatus:(Reachability*)curReach
{
    if(curReach == _wifiReach)
    {
        if(curReach.currentReachabilityStatus != NotReachable)
        {
            _isWifiAvailable = YES;
            NSLog(@"reachabilityChanged wifi is available");
        }
        else 
        {
            _isWifiAvailable = NO;
            NSLog(@"reachabilityChanged wifi is not available");
        }
    }
    else if(curReach == _internetReach)
    {
        if(curReach.currentReachabilityStatus != NotReachable)
        {
            _isMobileNetAvailable = YES;
            NSLog(@"reachabilityChanged GPRS/3G is available");
        }
        else 
        {
            _isMobileNetAvailable = NO;
            NSLog(@"reachabilityChanged GPRS/3G is not available");
        }
    }
    
}

-(BOOL)testHostAvailable
{
    long long curTime = [TimeUtil getCurrentTime];
    
    if((curTime - _lastCheckWebEnableTime) < _hostTestIntervalMillisecond)
    {
        return _isHostAvailable;
    }
    
    //test host
    BOOL hostUrlTestResult = [self testHostUrl];
    
    _lastCheckWebEnableTime = curTime;
    
    _isHostAvailable = hostUrlTestResult;
    
    return _isHostAvailable;
}

- (BOOL)testHostUrl
{
    NSURL* hostURL = [NSURL URLWithString:_hostTestUrl];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:hostURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_hostTestTimeoutMilisecond];
    
    [request setHTTPMethod:@"GET"];
    //[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSHTTPURLResponse* response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    if(response.statusCode == HTTP_STATUS_CODE_SUCCESS)
    {
        return YES;
    }
    else 
    {
        return NO;
    }
}

@end
