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

/**
 * 生成MD5 sum(结果与linux上md5sum相同)
 */
+ (NSString*)md5Sum:(NSString*)filePath;

@end
