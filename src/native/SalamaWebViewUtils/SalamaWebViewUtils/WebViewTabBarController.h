//
//  WebViewTabBarController.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-10.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseWebViewController.h"

@interface WebViewTabBarController : BaseWebViewController
{
@private
    UIWebView* _tabBarView;
    NSMutableArray* _viewControllers;
    NSString* _tabBarViewLocalPage;
    NSMutableArray* _webViewMenuArray;
    
    CGRect _tabBarFrame;
    CGRect _tabContentFrame;
    
    int _selectedTabIndex;
    
    BOOL _viewInited;
}

#pragma mark - basic tab bar control
@property(nonatomic, assign) CGRect tabContentFrame;
@property(nonatomic, assign) CGRect tabBarFrame;
@property(nonatomic, readonly) NSMutableArray* viewControllers;

/**
 * 设置当前tab的索引
 * @param tabIndex tab的索引(0开始)
 */
- (void)setSelectedTabIndex:(int)tabIndex;

/**
 * 取得当前tab的索引(0开始)
 */
- (int)getSelectedTabIndex;

/**
 * 设置TabBar隐藏
 * @param hidden YES:隐藏 NO:显示
 */
- (void)setTabBarHidden:(BOOL)hidden;

#pragma mark - webview tab bar control

/**
 * 设置web view tab bar的页面名
 * @param localPage 页面名
 */
- (void)setWebViewTabBarLocalPage:(NSString*)localPage;

/**
 * 取得web view tab bar的页面名
 */
- (NSString*)getWebViewTabBarLocalPage;

/**
 * 取得是否Web View菜单处于隐藏状态
 * @return YES:隐藏中 NO:显示中
 */
- (int)isWebViewMenuHidden;

/**
 * 取得是否Web View菜单处于隐藏状态
 * @param localPage 页面名
 * @return YES:隐藏中 NO:显示中
 */
- (int)isWebViewMenuHidden:(NSString*)localPage;

/**
 * 显示菜单(菜单以WebView构造)
 * @param localPage 页面名
 * @param x
 * @param y
 * @param width
 * @param height
 */
- (void)showWebViewMenuWithLocalPage:(NSString*)localPage x:(int)x y:(int)y width:(int)width height:(int)height;

/**
 * 隐藏菜单(菜单以WebView构造)
 * @param localPage 页面名
 */
- (void)hideWebViewMenuWithLocalPage:(NSString*)localPage;

/**
 * 隐藏菜单(菜单以WebView构造)
 */
- (void)hideWebViewMenu;

/**
 * 显示已经显示过的菜单(菜单以WebView构造)
 * @param x
 * @param y
 * @param width
 * @param height
 */
- (void)showWebViewMenu:(UIWebView *)webView x:(int)x y:(int)y width:(int)width height:(int)height;

/**
 * 隐藏菜单(菜单以WebView构造)
 * @param webView 
 */
- (void)hideWebViewMenu:(UIWebView *)webView;
@end
