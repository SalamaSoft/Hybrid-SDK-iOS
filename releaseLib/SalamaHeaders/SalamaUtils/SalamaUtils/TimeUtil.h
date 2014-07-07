//
//  TimeUtil.h
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-14.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject

/**
 * 取得当前UTC时间毫秒数(格林威治时间1970/1/1 00:00:00起计算的毫秒数，计算方法和Java,.Net等相同)
 */
+(long long) getCurrentTime;

/**
 * 格式化日期(yyyy-MM-dd)
 * @param date 日期
 * @return 格式化后的字符串
 */
+(NSString*) formatToYYYYMMDDfromDate:(NSDate*)date;

/**
 * 格式化日期(yyyy-MM-dd HH:mm:ss)
 * @param date 日期
 * @return 格式化后的字符串
 */
+(NSString*) formatToYYYYMMDDHHMMSSfromDate:(NSDate*)date;

@end
