//
//  LocalWebViewController.h
//  MoreGifts
//
//  Created by XingGu Liu on 12-5-19.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebVariableStack.h"

@interface LocalWebViewController : UIViewController<UIWebViewDelegate, WebVariableStack>
{
    @protected
    UIWebView* _webView;
    UIScrollView* _scrollViewOfWebView;
    BOOL _webViewLoadedFlg;
    
    //dispatch_queue_t nativeServiceQueue;
    
    //WebVariableStack for scope:page
    NSMutableDictionary* _webVariableStackForScopePage;
    NSMutableDictionary* _webVariableStackForScopeTemp;
    
    //ViewService
    NSString* _thisViewServiceClassName;
    id _thisViewService;

    //transition parameters' container
    NSMutableDictionary* _transitionParams;
    
}

/**
 * WebView
 */
@property (nonatomic, unsafe_unretained) IBOutlet UIWebView* webView;

/**
 * 页面名
 */
@property (nonatomic, retain) NSString* localPage;

/**
 * webView所在的UIScrollView
 */
@property (nonatomic, readonly) UIScrollView* scrollViewOfWebView;

/**
 * ThisViewService类型名
 */
@property (nonatomic, retain) NSString* thisViewServiceClassName;

/**
 * ThisViewService
 */
@property (nonatomic, retain) id thisViewService;

/**
 * 初始化
 * @viewServiceName Class name of thisViewService
 */
- (id)initWithViewServiceName:(NSString*)viewServiceClassName;

/**
 * 装载本地页面
 */
-(void)loadLocalPage:(NSString*)localPage;

/**
 * 日志输出
 * @param msg 日志消息
 */
-(void)log:(NSString*)msg;

/**
 * 调用JavaScript函数
 * @param functionName 函数名
 * @param params 参数列表
 */
-(NSString*)callJavaScript:(NSString*)functionName params:(NSArray*)params;

/**
 * 调用JavaScript函数完成后的回调函数
 */
-(void)didCallJavascript:(NSString*)returnValue;

/**
 * 设置画面迁移参数
 * @param paramValue 参数值
 * @param paramName 参数名
 */
- (void)setTransitionParam:(id)paramValue paramName:(NSString*)paramName;

/**
 * 取得画面迁移参数
 * @param paramName 参数名
 * @return 参数值
 */
- (id)getTransitionParamByName:(NSString*)paramName;

/**
 * 设置session值
 * @param name 名称
 * @param value 值
 */
-(void)setSessionValueWithName:(NSString*)name value:(NSString*)value;

/**
 * 删除session值
 * @param name 名称
 */
-(void)removeSessionValueWithName:(NSString*)name;

/**
 * 取得session值
 * @param name 名称
 * @return session值
 */
-(NSString*)getSessionValueWithName:(NSString*)name;

@end
