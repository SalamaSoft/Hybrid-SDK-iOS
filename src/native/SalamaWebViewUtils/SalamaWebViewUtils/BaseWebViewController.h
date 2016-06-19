//
//  BaseWebViewController.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-10.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocalWebViewController.h"

#define NOTIFICATION_FOR_JAVASCRIPT_USER_INFO_RESULT_NAME @"result"

@class BaseWebViewController;
@interface WebViewAlertViewDelegateHandler : NSObject<UIAlertViewDelegate>

@property (nonatomic, unsafe_unretained) BaseWebViewController* viewController;

@end


@interface BaseWebViewController : LocalWebViewController
{
    @protected
    int _senderTagSeed;
    NSMutableDictionary* _senderTagToJSCallBackMapping;
    WebViewAlertViewDelegateHandler* _alertViewHandler;
    
    NSMutableDictionary* _notificationNameToJSCallBackMapping;
    UIActivityIndicatorView* _spinnerForWaiting;
}

#pragma mark - base method about event

- (int)getNewSenderTag;

- (void)registerJSCallBackToSender:(NSInteger)senderTag jsCallBack:(NSString*)jsCallBack;
- (NSString*)getJSCallBackWithSenderTag:(NSInteger)senderTag;

-(void)notifyToJSCallBack:(NSNotification *)notification;

#pragma mark - setting for JavaScript
/**
 * 注册JavaScript函数,同通知名绑定
 * @param notificationName 通知名
 * @param jsCallBack JavaScript回调函数
 */
- (void)registerJSCallBackToNotification:(NSString*)notificationName jsCallBack:(NSString*)jsCallBack;

#pragma mark - UI operation helper
/**
 * 显示Alert画面
 * @param title 标题
 * @param message 消息内容
 * @param buttonTitleList 按钮标题列表
 * @param jsCallBack JavaScript函数
 */
- (void)showAlert:(NSString*)title message:(NSString*)message buttonTitleList:(NSArray*)buttonTitleList  jsCallBack:(NSString*)jsCallBack;

/**
 * 显示装载等待动画
 * @param spinnerUIStyle 风格。此参数仅为保持和iOS版兼容，Android中不起作用。
 */
- (void)startWaitingSpinnerAnimating:(int)spinnerUIStyle;

/**
 * 停止装载等待动画
 */
- (void)stopWaitingSpinnerAnimating;


@end
