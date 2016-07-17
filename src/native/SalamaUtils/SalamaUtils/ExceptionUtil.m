//
//  ExceptionUtil.m
//  SalamaDeveloper
//
//  Created by Liu Xinggu on 13-7-25.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "ExceptionUtil.h"

@implementation ExceptionUtil

+ (void)outputException:(NSException *)exception
{
    NSString* name = [ exception name ];
    NSString* reason = [ exception reason ];
    NSArray* symbols = [ exception callStackSymbols ]; // 异常发生时的调用栈
    NSMutableString* strSymbols = [ [ NSMutableString alloc ] init ]; // 将调用栈拼成输出日志的字符串
    for (NSString* item in symbols )
    {
        [ strSymbols appendString: item ];
        [ strSymbols appendString: @"\r\n" ];
    }
    
    NSLog(@"Uncaught Exception name:[%@] reason:[%@] symbols:\r\n%@", name, reason, strSymbols);
}

@end
