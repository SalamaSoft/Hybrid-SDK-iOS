//
//  ResourceDownloadDelegate.h
//  SalamaDataService
//
//  Created by Liu XingGu on 12-10-3.
//
//

#import <Foundation/Foundation.h>

@protocol ResourceDownloadHandler <NSObject>

@optional
/**
 * 下载资源文件
 * @param resId 资源Id
 * @param saveTo 保存路径
 * @return 文件内容
 */
//- (NSData*)downloadByResId:(NSString*)resId;
- (BOOL)downloadByResId:(NSString*)resId saveTo:(NSString*)saveTo;

@end
