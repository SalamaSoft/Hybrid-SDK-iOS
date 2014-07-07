//
//  PropertyInfoUtil.h
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-15.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PropertyInfoUtil : NSObject

/**
 * 取得属性列表
 * @return 属性列表
 */
+(NSArray*) getPropertyInfoArray:(Class)dataCls;

//Dictionary of PropertyInfo. Key:propertyName value:propertyInfo
/**
 * 取得属性字典
 * key:属性名 value:属性
 * @return 属性字典
 */
+(NSDictionary*) getPropertyInfoMap:(Class)dataCls;

@end
