//
//  BaseAppService.h
//  SalamaBaseApp
//
//  Created by XingGu Liu on 16/6/17.
//  Copyright © 2016年 Salama Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SalamaDataService.h"
#import "SalamaNativeService.h"
#import "WebController.h"
#import "WebManager.h"

#define DEFAULT_WEB_PACKAGE_DIR @"html"
#define DEFAULT_WEB_RESOURCE_DIR @"res"

@interface BaseAppService : NSObject
{
    @protected
    NSString* _udid;
    int _httpRequestTimeoutSeconds;
    NSString* _webPackageDirName;
    NSString* _webResourceDirName;
    
    
    NSString* _bundleId;
    SalamaDataService* _dataService;
    NSString* _systemLanguage;
    NSString* _textFileName;

    
    SalamaNativeService* _nativeService;
    WebService* _webService;
    
    
    NSLock* _lockForNewDataId;
    NSInteger _dataIdSeq;
}

@property (nonatomic, readonly) NSString* udid;

@property (nonatomic, readonly) NSString* bundleId;
@property (nonatomic, readonly) NSString* systemLanguage;

@property (nonatomic, readonly) SalamaDataService* dataService;
@property (nonatomic, readonly) WebService* webService;

@property (nonatomic, readonly) SalamaNativeService* nativeService;

+ (bool)isDebugMode;
+ (void)setDebugMode:(bool)isDebug;

- (id)initWithUdid:(NSString*)udid httpRequestTimeoutSeconds:(int)httpRequestTimeoutSeconds webPackageDirName:(NSString*)webPackageDirName webResourceDirName:(NSString*)webResourceDirName;

/**
 * 取得text_xx.strings的内容，其中的xx为当前系统语言的2字符前缀。英语:en，简体汉语:zh，法语:fr，德语:de，日语:ja。
 * 其他的语言参考IOS的文档中提供的链接 http://www.loc.gov/standards/iso639-2/php/English_list.php
 * 如果系统语言对应的text_xx.strings文件不存在，则读取text_en.strings。
 * @param key text内容的key
 * @return text内容
 */
- (NSString*)getTextByKey:(NSString*)key;

/**
 * 生成dataId(可以作为本地数据库的数据主键)
 * 采用较为简单的方法：<udid> + <UTC>。方法内有锁，线程安全。但1秒只能产生1000个。
 */
- (NSString*)generateNewDataId;


@end
