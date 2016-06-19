//
//  FileService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-3.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileService : NSObject

/**
 * 取得实际物理存储上的路径
 * @param virtualPath 虚拟路径(/xxx，根路径对应html目录)
 * @return 实际物理存储上的路径
 */
- (NSString*)getRealPathByVirtualPath:(NSString*)virtualPath;

/**
 * 文件是否存在
 * @param filePath 文件路径
 * @return 1:是  0:否
 */
- (int)isExistsFile:(NSString*)filePath;

/**
 * 路径是否存在，并且是否目录
 * @param filePath 目录路径
 * @return 1:是  0:否
 */
- (int)isExistsDir:(NSString*)dirPath;

/**
 * 取得临时文件目录
 * @return 临时文件目录路径
 */
- (NSString*)getTempDirPath;


/**
 * 文件拷贝
 * @param from 源文件路径
 * @param to 目标文件路径
 * @return 目标文件路径
 */
- (NSString*)copyFileFrom:(NSString*)from to:(NSString*)to;

/**
 * 文件移动
 * @param from 源文件路径
 * @param to 目标文件路径
 * @return 目标文件路径
 */
- (NSString*)moveFileFrom:(NSString*)from to:(NSString*)to;

/**
 * 文本方式读取文件内容(utf-8编码方式)
 * @param filePath 文件路径
 * @return 文件内容
 */
- (NSString*)readAllText:(NSString*)filePath;

/**
 * 写入文本文件(文件不存在的话，被创建。文件存在的话，原内容被冲掉)(utf-8编码方式)
 * @param filePath 文件路径
 * @return 文件路径
 */
- (NSString*)writeTextToFile:(NSString*)filePath text:(NSString*)text;

/**
 * 追加写入文本文件(文件不存在的话，被创建。文件存在的话，在原内容末尾追加)
 * @param filePath 文件路径
 * @return 文件路径
 */
- (NSString*)appendTextToFile:(NSString*)filePath text:(NSString*)text;

/**
 * 统计目录所有文件用量(单位byte)
 * @return 目录所有文件用量(单位byte)
 */
- (long long)calculateVolumeOfDir:(NSString*)dirPath;

/**
 * 列出目录下所有文件名(不递归)
 * @param dirPath 目录路径
 * @param isIncludeSubDir 是否包含子目录
 * @return 文件名列表
 */
- (NSArray*)listFileNamesInDir:(NSString*)dirPath isIncludeSubDir:(int)isIncludeSubDir;

/**
 * 列出目录下所有文件路径(不递归)
 * @param dirPath 目录路径
 * @param isIncludeSubDir 是否包含子目录
 * @return 文件路径列表
 */
- (NSArray*)listFilesInDir:(NSString*)dirPath isIncludeSubDir:(int)isIncludeSubDir;

/**
 * 列出目录下所有文件路径(递归)
 * @param dirPath 目录路径
 * @return 文件路径列表
 */
- (NSArray*)listFilesRecursivelyInDir:(NSString*)dirPath;

/**
 * 删除文件
 * @param filePath 文件路径
 * @return 文件路径
 */
- (NSString*)deleteFile:(NSString*)filePath;

/**
 * 删除目录(递归)
 * @param dirPath 目录路径
 * @return 目录路径
 */
- (NSString*)deleteDir:(NSString*)dirPath;

/**
 * 创建目录(可以创建多层目录)
 * @param dirPath 目录路径
 * @return 目录路径
 */
- (NSString*)mkdir:(NSString*)dirPath;

/**
 * 压缩文件
 * @param filePath
 * @param zipPath
 * @return zipPath
 */
- (NSString*)compressZipFromFile:(NSString*)filePath toZipPath:(NSString*)zipPath;

/**
 * 压缩文件
 * @param dirPath
 * @param zipPath
 * @return zipPath
 */
- (NSString*)compressZipFromDir:(NSString*)dirPath toZipPath:(NSString*)zipPath;

/**
 * 解压缩文件
 * @param zipPath
 * @param toDir
 * @return toDir
 */
- (NSString*)decompressZip:(NSString*)zipPath toDir:(NSString*)toDir;

@end
