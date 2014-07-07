//
//  TimeUtil.m
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-14.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil

+(long long) getCurrentTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;

    return (long long)time;
}

+(NSString *)formatToYYYYMMDDfromDate:(NSDate *)date
{
    NSDateFormatter* dateFormatter =  [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *)formatToYYYYMMDDHHMMSSfromDate:(NSDate *)date
{
    NSDateFormatter* dateFormatter =  [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

@end
