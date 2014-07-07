//
//  MD5Util.h
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Util : NSObject

/**
 * 生成MD5序列
 */
+ (NSString*)md5String:(NSString*)inputStr;

@end
