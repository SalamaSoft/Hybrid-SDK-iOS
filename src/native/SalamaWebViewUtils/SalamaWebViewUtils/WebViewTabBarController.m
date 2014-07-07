//
//  WebViewTabBarController.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-10.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "WebViewTabBarController.h"

#import "WebManager.h"

@interface WebViewTabBarController ()

- (void)initObjs;
- (void)initTabBarController;

- (void) showTabContentViewController: (UIViewController*) content;
- (void) hideTabContentViewController: (UIViewController*) content;

- (UIWebView*)createWebViewWithFrame:(CGRect)webViewFrame;

@end

#define DEFAULT_TAB_BAR_HEIGHT 49

@implementation WebViewTabBarController

@synthesize tabBarFrame = _tabBarFrame;
@synthesize tabContentFrame = _tabContentFrame;
@synthesize viewControllers = _viewControllers;

- (void)setTabBarFrame:(CGRect)barFrame
{
    _tabBarFrame = barFrame;
    
    if(_tabBarView != nil)
    {
        _tabBarView.frame = _tabBarFrame;
    }
}

- (void)setTabContentFrame:(CGRect)contentFrame
{
    _tabContentFrame = contentFrame;
    
    if(_selectedTabIndex < _viewControllers.count)
    {
        ((UIViewController*)[_viewControllers objectAtIndex:_selectedTabIndex]).view.frame = contentFrame;
    }
}

- (int)getSelectedTabIndex
{
    return _selectedTabIndex;
}

- (void)setSelectedTabIndex:(int)tabIndex
{
    if(_viewInited)
    {
        [self hideTabContentViewController:[_viewControllers objectAtIndex:_selectedTabIndex]];
        
        _selectedTabIndex = tabIndex;
        
        [self showTabContentViewController:[_viewControllers objectAtIndex:_selectedTabIndex]];
    }
    else
    {
        _selectedTabIndex = tabIndex;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initObjs];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self initTabBarController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"WebViewTabBarController didReceiveMemoryWarning()");
}

- (void)initObjs
{
    _viewControllers = [[NSMutableArray alloc] init];
    _webViewMenuArray = [[NSMutableArray alloc] init];
    
    _tabBarFrame = CGRectMake(0, 0, 0, 0);
    _tabContentFrame = CGRectMake(0, 0, 0, 0);
    
    _selectedTabIndex = 0;
    
    _viewInited = NO;
}

- (void)initTabBarController
{
    SSLogDebug(@"bounds:%f,%f,%f,%f", self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    
    if(_tabBarFrame.size.height == 0)
    {
        _tabBarFrame = CGRectMake(0, self.view.bounds.size.height - DEFAULT_TAB_BAR_HEIGHT, self.view.bounds.size.width, DEFAULT_TAB_BAR_HEIGHT);
        
        _tabContentFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - DEFAULT_TAB_BAR_HEIGHT);
    }
    
    if(_tabBarView == nil)
    {
        _tabBarView = [self createWebViewWithFrame:_tabBarFrame];
        [[WebManager webController] loadLocalPage:_tabBarViewLocalPage webView:_tabBarView];
    }
    else
    {
        _tabBarView.frame = _tabBarFrame;
    }
    _tabBarView.delegate = self;
    [self.view addSubview:_tabBarView];
    
    [self showTabContentViewController:[_viewControllers objectAtIndex:_selectedTabIndex]];
    
    _viewInited = YES;
}

- (void) showTabContentViewController: (UIViewController*) content
{
    [self addChildViewController:content];                 // 1
    content.view.frame = _tabContentFrame; // 2
    [self.view addSubview:content.view];
    [content didMoveToParentViewController:self];          // 3
    
    [self.view bringSubviewToFront:_tabBarView];
}

- (void) hideTabContentViewController: (UIViewController*) content
{
    [content willMoveToParentViewController:nil];  // 1
    [content.view removeFromSuperview];            // 2
    [content removeFromParentViewController];      // 3
}

- (void)setTabBarHidden:(BOOL)hidden
{
    _tabBarView.hidden = hidden;
}

#pragma mark - webview tab bar control

- (void)setWebViewTabBarLocalPage:(NSString*)localPage
{
    _tabBarViewLocalPage = localPage;
    
    if(_tabBarView != nil)
    {
        [[WebManager webController] loadLocalPage:localPage webView:_tabBarView];
    }
}

- (NSString*)getWebViewTabBarLocalPage
{
    return _tabBarViewLocalPage;
}

- (int)isWebViewMenuHidden
{
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if(!((UIWebView*)[_webViewMenuArray objectAtIndex:i]).hidden)
        {
            return 0;
        }
    }
    
    return 1;
}

- (int)isWebViewMenuHidden:(NSString *)localPage
{
    UIWebView* menuView = nil;
    NSURL *url = [NSURL fileURLWithPath:[[WebManager webController] toRealPath:localPage]];
    NSString* urlPath = url.path;
    
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if([((UIWebView*)[_webViewMenuArray objectAtIndex:i]).request.URL.path isEqualToString:urlPath])
        {
            menuView = [_webViewMenuArray objectAtIndex:i];
            break;
        }
    }
    
    if(menuView != nil)
    {
        return menuView.hidden?1:0;
    }
    else
    {
        return 1;
    }
}

- (void)showWebViewMenuWithLocalPage:(NSString *)localPage x:(int)x y:(int)y width:(int)width height:(int)height
{
    UIWebView* menuView = nil;
    NSURL *url = [NSURL fileURLWithPath:[[WebManager webController] toRealPath:localPage]];
    NSString* urlPath = url.path;
    
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if([((UIWebView*)[_webViewMenuArray objectAtIndex:i]).request.URL.path isEqualToString:urlPath])
        {
            menuView = [_webViewMenuArray objectAtIndex:i];
            break;
        }
    }
    
    if(menuView == nil)
    {
        menuView = [self createWebViewWithFrame:CGRectMake(x, y, width, height)];
        [menuView loadRequest:[NSURLRequest requestWithURL:url]];
        [_webViewMenuArray addObject:menuView];
        
        [self.view addSubview:menuView];
    }
    else
    {
        menuView.frame = CGRectMake(x, y, width, height);
    }

    [self.view bringSubviewToFront:menuView];
    menuView.hidden = NO;
}

- (void)hideWebViewMenuWithLocalPage:(NSString *)localPage
{
    UIWebView* menuView = nil;
    NSURL *url = [NSURL fileURLWithPath:[[WebManager webController] toRealPath:localPage]];
    NSString* urlPath = url.path;
    
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if([((UIWebView*)[_webViewMenuArray objectAtIndex:i]).request.URL.path isEqualToString:urlPath])
        {
            menuView = [_webViewMenuArray objectAtIndex:i];
            break;
        }
    }
    
    if(menuView != nil)
    {
        menuView.hidden = YES;
    }
}

- (void)hideWebViewMenu
{
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if(!((UIWebView*)[_webViewMenuArray objectAtIndex:i]).hidden)
        {
            ((UIWebView*)[_webViewMenuArray objectAtIndex:i]).hidden = YES;
        }
    }
}

- (void)showWebViewMenu:(UIWebView *)webView x:(int)x y:(int)y width:(int)width height:(int)height
{
    UIWebView* menuView = nil;
    NSURL *url = webView.request.URL;
    NSString* urlPath = url.path;
    
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if([((UIWebView*)[_webViewMenuArray objectAtIndex:i]).request.URL.path isEqualToString:urlPath])
        {
            menuView = [_webViewMenuArray objectAtIndex:i];
            break;
        }
    }
    
    if(menuView == nil)
    {
        menuView.frame = CGRectMake(x, y, width, height);

        [_webViewMenuArray addObject:menuView];
        [self.view addSubview:menuView];
    }
    else
    {
        menuView.frame = CGRectMake(x, y, width, height);
    }
    
    [self.view bringSubviewToFront:menuView];
    menuView.hidden = NO;
}

- (void)hideWebViewMenu:(UIWebView *)webView
{
    UIWebView* menuView = nil;
    NSURL *url = webView.request.URL;
    NSString* urlPath = url.path;
    
    for(int i = 0; i < _webViewMenuArray.count; i++)
    {
        if([((UIWebView*)[_webViewMenuArray objectAtIndex:i]).request.URL.path isEqualToString:urlPath])
        {
            menuView = [_webViewMenuArray objectAtIndex:i];
            break;
        }
    }
    
    if(menuView != nil)
    {
        menuView.hidden = YES;
    }
}

- (UIWebView *)createWebViewWithFrame:(CGRect)webViewFrame
{
    UIWebView* webV = [[UIWebView alloc] init];
    //webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //webV.autoresizingMask = UIViewAutoresizingNone;
    webV.frame = CGRectMake(webViewFrame.origin.x, webViewFrame.origin.y, webViewFrame.size.width, webViewFrame.size.height);
    [(UIScrollView *)[[_webView subviews] objectAtIndex:0] setBounces:NO];
    [(UIScrollView *)[[_webView subviews] objectAtIndex:0] setScrollEnabled:NO];
    
    return webV;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self setWebView:webView];
    
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

@end
