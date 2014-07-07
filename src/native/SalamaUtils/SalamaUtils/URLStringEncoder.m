//
//  URLStringEncoder.m
//  SalamaUtilsTest
//
//  Created by Liu XingGu on 12-9-28.
//
//

#import "URLStringEncoder.h"

@implementation URLStringEncoder

+ (NSString *)decodeURLString:(NSString *)urlStr
{
    NSMutableString *resultString = [NSMutableString stringWithString:urlStr];
    
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)encodeURLString:(NSString *)urlStr
{
    /*
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)urlStr,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);

    NSString* encodedStr = (__bridge_transfer NSString*) escaped;
    */
    return [[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
}

@end
