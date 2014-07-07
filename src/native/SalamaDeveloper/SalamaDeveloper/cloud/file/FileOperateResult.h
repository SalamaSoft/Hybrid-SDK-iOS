//
//  FileOperateResult.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-7-31.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileOperateResult : NSObject

/**
 * fileId
 */
@property (nonatomic, retain) NSString* fileId;

/**
 * 成功标识(1:成功 0:失败)
 */
@property (nonatomic, assign) int success;

@end
