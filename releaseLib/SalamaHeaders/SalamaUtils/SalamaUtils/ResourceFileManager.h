//
//  ResourceFileManager.h
//  
//
//  Created by XingGu Liu on 12-6-6.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceFileManager : NSObject
{
    @protected
    NSFileManager* _fileManager;
    NSString* _storageDirPath;
}

/**
 * 初始化
 * @param storageDirPath 存放文件的目录路径
 */
-(id)initWithStorageDirPath:(NSString*)storageDirPath;

/**
 * 取得设置的存放目录路径
 */
-(NSString*)fileStorageDirPath;

/**
 * 取得资源文件路径
 * @param resId 资源文件ID(即文件名)
 * @return 资源文件路径
 */
-(NSString*)getResourceFilePath:(NSString*)resId;

/**
 * 资源文件是否存在
 * @param resId 资源文件ID(即文件名)
 * @return YES:存在 NO:不存在
 */
-(BOOL)isResourceFileExists:(NSString*)resId;

/**
 * 变更资源文件名
 * @param resId 原文件名
 * @param resId 新文件名
 */
-(void)changeResId:(NSString*)resId toResId:(NSString*)toResId;

/**
 * 保存资源文件
 * @param data:文件数据
 * @param resId 文件名
 */
-(void)saveResourceFileWithNSData:(NSData*)data resId:(NSString*)resId;

@end
