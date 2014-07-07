//
//  WebVariableStack.h
//  SalamaUtilsTest
//
//  Created by XingGu Liu on 12-9-12.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebVariableStack <NSObject>

/**
 * WebVariableStackScopePage 临时变量范围(当前页面)
 * WebVariableStackScopeTemp 临时变量范围(本次调用)
 */
typedef enum WebVariableStackScope {
    WebVariableStackScopePage = 0,
    WebVariableStackScopeTemp
} WebVariableStackScope;

@required
/**
 * 清空返回值临时变量
 */
- (void)clearVariablesOfAllScope;

/**
 * 清空返回值临时变量
 * @param scope 指定范围
 */
- (void)clearVariablesOfScope:(WebVariableStackScope)scope;

/**
 * 设置返回值临时变量
 * @param value 值
 * @param name 名称
 * @param scope 范围
 */
- (void)setVariable:(id)value name:(NSString*)name scope:(WebVariableStackScope)scope;

/**
 * 取得临时变量值
 * @param name 名称
 * @param scope 范围
 * @return 临时变量值
 */
- (id)getVariable:(NSString*)name scope:(WebVariableStackScope)scope;

/**
 * 删除临时变量
 * @param name 名称
 * @param scope 范围
 */
- (void)removeVariable:(NSString*)name scope:(WebVariableStackScope)scope;


@end
