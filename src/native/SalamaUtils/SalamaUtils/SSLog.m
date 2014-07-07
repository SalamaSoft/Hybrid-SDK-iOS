//
//  SSLog.m
//  SalamaWebCore
//
//  Created by Liu XingGu on 12-11-2.
//
//

#import "SSLog.h"

//MACRO example
//# define DLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);



static SSLogLevel _SSLogLevel = SSLogLevelDebug;

void SetSSLogLevel(SSLogLevel logLevel)
{
    _SSLogLevel = logLevel;
}

void SSLogOutput(SSLogLevel logLevel, id format, ...)
{
    if(logLevel >= _SSLogLevel)
    {
        va_list args;
        
        if(format)
        {
            va_start(args, format);
            
            NSLogv(format, args);
            
            va_end(args);
        }
    }
}
