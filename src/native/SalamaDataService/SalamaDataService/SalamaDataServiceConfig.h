//
//  SalamaDataServiceConfig.h
//  SalamaDataService
//
//  Created by Liu XingGu on 12-10-4.
//
//

#import <Foundation/Foundation.h>

@interface SalamaDataServiceConfig : NSObject

/**
 * 请求timeout秒数
 */
@property (nonatomic, assign) int httpRequestTimeout;

/**
 * 资源文件保存目录路径
 * @return 资源文件保存目录路径
 */
@property (nonatomic, retain) NSString* resourceStorageDirPath;

/**
 * 数据库文件名
 */
@property (nonatomic, retain) NSString* dbName;

/**
 * 数据库目录路径
 */
@property (nonatomic, retain) NSString* dbDirPath;



@end
