//
//  SSLog.h
//  SalamaWebCore
//
//  Created by Liu XingGu on 12-11-2.
//
//

#import <Foundation/Foundation.h>

typedef enum SSLogLevel
{
    SSLogLevelDebug = 0,
    SSLogLevelInfo,
    SSLogLevelWarn,
    SSLogLevelError
} SSLogLevel;

/**
 * 设置日志输出Level
 * @param logLevel
 */
void SetSSLogLevel(SSLogLevel logLevel);

//# define DLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#define SSLogDebug(fmt, ...) SSLogOutput(SSLogLevelDebug, (@"%s[line:%d]: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SSLogInfo(fmt, ...) SSLogOutput(SSLogLevelInfo, (@"%s[line:%d]: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SSLogWarn(fmt, ...) SSLogOutput(SSLogLevelWarn, (@"%s[line:%d]: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);

#define SSLogError(fmt, ...) SSLogOutput(SSLogLevelError, (@"%s[line:%d]: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);

void SSLogOutput(SSLogLevel logLevel, id format, ...);
