//
//  SalamaNativeService.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-11.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FileService.h"
#import "SqlService.h"

@interface SalamaNativeService : NSObject
{
    @private
    FileService* _fileService;
    SqlService* _sqlService;
}

- (id)initWithDataService:(SalamaDataService*) dataService;

/**
 * 取得FileService实例
 * @return FileService实例
 */
@property (nonatomic, readonly) FileService* fileService;

/**
 * 取得SqlService实例
 * @return SqlService实例
 */
@property (nonatomic, readonly) SqlService* sqlService;


@end
