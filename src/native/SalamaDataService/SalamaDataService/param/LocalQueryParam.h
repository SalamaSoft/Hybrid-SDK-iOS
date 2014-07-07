//
//  LocalQueryParam.h
//  SalamaDataService
//
//  Created by Liu XingGu on 12-10-5.
//
//

#import <Foundation/Foundation.h>

@interface LocalQueryParam : NSObject<NSCopying>

/**
 * SQL文
 */
@property (nonatomic, retain) NSString* sql;

/**
 * 数据类型
 */
@property (nonatomic, retain) NSString* dataClass;

/**
 * 资源字段名(逗号分隔)
 */
@property (nonatomic, retain) NSString* resourceNames;

/**
 * 资源下载通知名
 */
@property (nonatomic, retain) NSString* resourceDownloadNotification;

@end
