//
//  URLStringEncoder.h
//  SalamaUtilsTest
//
//  Created by Liu XingGu on 12-9-28.
//
//

#import <Foundation/Foundation.h>

@interface URLStringEncoder : NSObject

/**
 * 解码URL(百分号编码，和JavaScript的百分号编码一致，具体参考W3C的相关资料)
 * @param urlStr URL字符串
 * @param 解码后的URL
 */
+(NSString *)decodeURLString:(NSString*)urlStr;

/**
 * 编码URL(百分号编码，和JavaScript的百分号编码一致，具体参考W3C的相关资料)
 * @param urlStr URL字符串
 * @param 编码后的URL
 */
+(NSString *)encodeURLString:(NSString*)urlStr;

@end
