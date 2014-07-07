//
//  FileUtil.h
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

/**
 * 删除目录下的文件和目录(不递归子目录)
 * @return 返回操作的文件和目录的个数
 */
+ (int)removeAllItemsAtDir:(NSString *)dirPath;

/**
 * 拷贝目录下的文件至另一个目录(不递归子目录)
 * @return 返回操作的文件和目录的个数
 */
+ (int)copyFilesFromDir:(NSString*)srcDirPath destDir:(NSString*)destDirPath;

@end
