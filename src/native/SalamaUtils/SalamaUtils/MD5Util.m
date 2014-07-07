//
//  MD5Util.m
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "MD5Util.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation MD5Util

+ (NSString *)md5String:(NSString *)inputStr
{
	const char *cStr = [inputStr UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    //to compatible to Mysql's md5, make it to lowercase
	return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]] lowercaseString];
}

@end
