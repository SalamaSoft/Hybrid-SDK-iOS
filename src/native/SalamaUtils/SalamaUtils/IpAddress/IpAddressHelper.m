//
//  IpAddressHelper.m
//  
//
//  Created by XingGu Liu on 12-6-29.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "IpAddressHelper.h"

#import "IpAddress.h"

@implementation IpAddressHelper

+(NSString*)getCurrentIP
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();

    return [NSString stringWithFormat:@"%s", ip_names[1]];
    
}

@end
