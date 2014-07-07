//
//  CommonWebViewController.h
//  SalamaWebViewUtils
//
//  Created by XingGu Liu on 12-9-3.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseWebViewController.h"

@interface CommonWebViewController : BaseWebViewController
{
    @protected
    BOOL _isEnableOrientationPortrait;
    BOOL _isEnableOrientationPortraitUpsideDown;
    BOOL _isEnableOrientationLandscapeLeft;
    BOOL _isEnableOrientationLandscapeRight;

    NSMutableDictionary* _viewEventNameToJSCallBackMapping;
}

/**
 * 设置是否允许纵向显示(全局默认值)
 * @param isEnable 是否
 */
+ (void)setDefaultEnableOrientationPortrait:(BOOL)isEnable;

/**
 * 设置是否允许纵向颠倒显示(全局默认值)
 * @param isEnable 是否
 */
+ (void)setDefaultEnableOrientationPortraitUpsideDown:(BOOL)isEnable;

/**
 * 设置是否允许左侧横向显示(全局默认值)
 * @param isEnable 是否
 */
+ (void)setDefaultEnableOrientationLandscapeLeft:(BOOL)isEnable;

/**
 * 设置是否允许右侧横向显示(全局默认值)
 * @param isEnable 是否
 */
+ (void)setDefaultEnableOrientationLandscapeRight:(BOOL)isEnable;

#pragma mark - Operations of JavaScript in WebView
/**
 * 取得页面内容高度
 * @return 高度
 */
-(int)getWebContentHeight;

#pragma mark - UI operations
/**
 * 设置是否有弹性效果
 * @param isEnable 是否有
 */
- (void)setBounces:(BOOL)isEnable;

/**
 * 设置是否允许纵向显示
 * @param isEnable 是否
 */
- (void)setEnableOrientationPortrait:(BOOL)isEnable;

/**
 * 设置是否允许纵向颠倒显示
 * @param isEnable 是否
 */
- (void)setEnableOrientationPortraitUpsideDown:(BOOL)isEnable;

/**
 * 设置是否允许左侧横向显示
 * @param isEnable 是否
 */
- (void)setEnableOrientationLandscapeLeft:(BOOL)isEnable;

/**
 * 设置是否允许右侧横向显示
 * @param isEnable 是否
 */
- (void)setEnableOrientationLandscapeRight:(BOOL)isEnable;

/**
 0-1.0
 **/

/**
 * 设置是否隐藏导航栏
 * @param hidden 是否隐藏
 */
- (void)setNavigationBarHidden:(BOOL)hidden;

/**
 * 设置导航栏颜色
 * @param red 红(0-1.0)
 * @param green 绿(0-1.0)
 * @param blue 蓝(0-1.0)
 * @param alpha alpha(0-1.0)
 */
- (void)setNavigationBarTintColor:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

/**
 * 设置回退按钮标题
 * @param title 标题
 */
- (void)setBackBarButtonOfNavigationBarWithTitle:(NSString*)title;

/**
 * 设置左侧按钮
 * @param title 标题
 * @param jsCallBack 点击事件的JavaScript回调函数
 */
- (void)setLeftBarButtonOfNavigationBarWithTitle:(NSString*)title jsCallBack:(NSString*)jsCallBack;

/**
 * 设置左侧按钮
 * @param imageName 按钮图片
 * @param jsCallBack 点击事件的JavaScript回调函数
 */
- (void)setLeftBarButtonOfNavigationBarWithImageNamed:(NSString*)imageName jsCallBack:(NSString*)jsCallBack;

/**
 * 设置左侧按钮
 * @param imageResId 按钮图片资源Id
 * @param jsCallBack 点击事件的JavaScript回调函数
 */
- (void)setLeftBarButtonOfNavigationBarWithImageResId:(NSString*)imageResId jsCallBack:(NSString*)jsCallBack;

/**
 * 将jsCallBack同画面事件绑定
 * @param eventName 画面事件名
 * 支持的事件名: viewDidUnload, viewWillUnload, viewDidAppear, viewWillDisappear, viewDidDisappear
 * @param jsCallBack JavaScript回调函数
 */
- (void)registerJSCallBackToViewEvent:(NSString*)eventName jsCallBack:(NSString*)jsCallBack;

#pragma mark - ViewController transition
/**
 * 创建页面View
 * @param pageName 页面名
 * @return 页面View
 */
- (CommonWebViewController*)createPageView:(NSString*)pageName;

/**
 * 创建页面View
 * @param pageName 页面名
 * @param commonWebViewControllerClassName 页面View类型名
 * @return 页面View
 */
- (id)createPageView:(NSString*)pageName commonWebViewControllerClassName:(NSString*)commonWebViewControllerClassName;

/**
 * 创建页面View
 * @param pageName 页面名
 * @param commonWebViewControllerClassName 页面View类型名
 * @param viewServiceClassName Class name of thisViewService
 * @return 页面View
 */
- (id)createPageView:(NSString*)pageName commonWebViewControllerClassName:(NSString*)commonWebViewControllerClassName viewServiceClassName:(NSString*)viewServiceClassName;

/**
 * push方式显示页面View
 * @param pageView 页面View
 * @param setIntoNavigationAsRoot 是否作为导航根画面
 */
- (void)pushPageView:(CommonWebViewController*)pageView setIntoNavigationAsRoot:(BOOL)setIntoNavigationAsRoot;

/**
 * push方式显示页面View
 * @param pageName 页面View
 */
- (void)pushPage:(NSString*)pageName;

/**
 * 返回上一个画面
 */
- (void)popSelf;

/**
 * 返回至根画面
 */
- (void)popToRoot;

/**
 * 返回至指定页面
 * @param pageName 页面名
 */
- (void)popToPage:(NSString*)pageName;

/**
 * present方式显示页面
 * @param pageView 页面View
 * @param setIntoNavigationAsRoot 是否作为导航根画面
 */
- (void)presentPageView:(CommonWebViewController*)pageView setIntoNavigationAsRoot:(BOOL)setIntoNavigationAsRoot;

/**
 * present方式显示页面
 * @param pageName 页面名
 * @param setIntoNavigationAsRoot 是否作为导航根画面
 */
- (void)presentPage:(NSString*)pageName setIntoNavigationAsRoot:(BOOL)setIntoNavigationAsRoot;
//- (void)dismissSelf;

/**
 * 关闭present方式显示的画面
 */
- (void)dismissSelf:(BOOL)animated;

/**
 * 开启WebView的滚动条
 */
- (void)enableScrollBar;

/**
 * 关闭WebView的滚动条
 */
- (void)disableScrollBar;

@end
