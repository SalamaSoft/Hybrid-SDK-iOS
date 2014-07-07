//
//  DefaultDBManager.h
//  SalamaDataCore
//
//  Created by XingGu Liu on 12-9-3.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBDataUtil.h"

/**
 * LocalDBLocationTypeDocuments 存储在Documents目录下
 * LocalDBLocationTypeLibraryCache 存储在Library/Cache目录下
 */
typedef enum LocalDBLocationType {LocalDBLocationTypeDocuments, LocalDBLocationTypeLibraryCache} LocalDBLocationType;

@interface DBManager : NSObject
{
    @private
    NSString* _dbFilePath;
}


/**
 * 取得数据库缺省存储目录路径
 * @param localDBLocationType 数据库存储位置类型
 * @return 数据库目录路径
 */
+ (NSString*)defaultDbDirPath:(LocalDBLocationType)localDBLocationType;

/**
 * 初始化函数
 * @param dbName 数据库文件名
 * @param dbDirPath 数据库存储目录路径
 * @return DBManager
 */
- (id)initWithDbName:(NSString *)dbName dbDirPath:(NSString *)dbDirPath;

/**
 * 创建DBDataUtil
 * @return DBDataUtil
 */
- (DBDataUtil *)createNewDBDataUtil;

@end
