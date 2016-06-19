//
//  CommonWebViewController.m
//  SalamaWebViewUtils
//
//  Created by XingGu Liu on 12-9-3.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "CommonWebViewController.h"

#import "WebManager.h"
#import "SimpleMetoXML.h"
#import "SSLog.h"
#import "ViewService.h"

@interface CommonWebViewController (PrivateMethod)

- (void)initView;
- (void)initWebView;
- (void)initObjs;

/********** Navigation Bar ***********/
- (void)barButtonClickDispatchToWeb:(id)sender;

@end

@implementation CommonWebViewController

#pragma mark - Init objects for this viewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //SSLogDebug(@"initWithNibName()");
        [self initView];
        [self initObjs];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self initWebView];
    
    //SSLogDebug(@"_thisViewService:%@",_thisViewService);
    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewDidLoad];
    }
    
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewDidLoad"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewDidUnload];
    }
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewDidUnload"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}

- (void)viewWillUnload
{
    [super viewWillUnload];
    
    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewWillUnload];
    }
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewWillUnload"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewWillAppear];
    }
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewWillAppear"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewWillDisappear];
    }
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewWillDisappear"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewDidAppear];
    }
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewDidAppear"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(_thisViewService != nil)
    {
        [(ViewService*)_thisViewService viewDidDisappear];
    }
    NSString* jsCallBack = [_viewEventNameToJSCallBackMapping objectForKey:@"viewDidDisappear"];
    if(jsCallBack != nil)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizesSubviews = YES;
}

- (void)initWebView
{
    if(self.webView == nil)
    {
        self.webView = [[UIWebView alloc] init];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.webView.delegate = self;
        [self.scrollViewOfWebView setBounces:NO];

        [self.view addSubview:self.webView];
    }
}

-(void)initObjs
{
    //orientation
    _isEnableOrientationPortrait = _isDefaultEnableOrientationPortrait;
    _isEnableOrientationPortraitUpsideDown = _isDefaultEnableOrientationPortraitUpsideDown;
    _isEnableOrientationLandscapeLeft = _isDefaultEnableOrientationLandscapeLeft;
    _isEnableOrientationLandscapeRight = _isDefaultEnableOrientationLandscapeRight;

    _viewEventNameToJSCallBackMapping = [[NSMutableDictionary alloc] init];
    
}

- (void)dealloc
{
    [_viewEventNameToJSCallBackMapping removeAllObjects];
    _viewEventNameToJSCallBackMapping = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SSLogWarn(@"CommonWebViewController(page:%@) didReceiveMemoryWarning", self.localPage);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (_isEnableOrientationPortrait && interfaceOrientation == UIInterfaceOrientationPortrait)
    || (_isEnableOrientationPortraitUpsideDown && interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    || (_isEnableOrientationLandscapeLeft && interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    || (_isEnableOrientationLandscapeRight && interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    ;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSUInteger orientations = 0;
    
    if(_isEnableOrientationPortrait)
    {
        orientations |= UIInterfaceOrientationMaskPortrait;
    }
    
    if(_isEnableOrientationLandscapeLeft)
    {
        orientations |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    
    if(_isEnableOrientationLandscapeRight)
    {
        orientations |= UIInterfaceOrientationMaskLandscapeRight;
    }
    
    if(_isEnableOrientationPortraitUpsideDown)
    {
        orientations |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return orientations;
}

#pragma mark - Operations about JavaScript in WebView

-(int)getWebContentHeight
{
    //NSString* bodyHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.clientHeight"];
    NSString* bodyHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    
    return [bodyHeight intValue];
}

#pragma mark - UI operations

- (void)setBounces:(BOOL)isEnable
{
    [self.scrollViewOfWebView setBounces:isEnable];
}

/********** Orientation ***********/
- (void)setEnableOrientationPortrait:(BOOL)isEnable
{
    _isEnableOrientationPortrait = isEnable;
}

- (void)setEnableOrientationPortraitUpsideDown:(BOOL)isEnable
{
    _isEnableOrientationPortraitUpsideDown = isEnable;
}

- (void)setEnableOrientationLandscapeLeft:(BOOL)isEnable
{
    _isEnableOrientationLandscapeLeft = isEnable;
}

- (void)setEnableOrientationLandscapeRight:(BOOL)isEnable
{
    _isEnableOrientationLandscapeRight = isEnable;
}

/********** Navigation Bar ***********/
static BOOL _isDefaultEnableOrientationPortrait = YES;
static BOOL _isDefaultEnableOrientationPortraitUpsideDown = NO;
static BOOL _isDefaultEnableOrientationLandscapeLeft = NO;
static BOOL _isDefaultEnableOrientationLandscapeRight = NO;

+ (void)setDefaultEnableOrientationPortrait:(BOOL)isEnable
{
    _isDefaultEnableOrientationPortrait = isEnable;
}

+ (void)setDefaultEnableOrientationPortraitUpsideDown:(BOOL)isEnable
{
    _isDefaultEnableOrientationPortraitUpsideDown = isEnable;
}

+ (void)setDefaultEnableOrientationLandscapeLeft:(BOOL)isEnable
{
    _isDefaultEnableOrientationLandscapeLeft = isEnable;
}

+ (void)setDefaultEnableOrientationLandscapeRight:(BOOL)isEnable
{
    _isDefaultEnableOrientationLandscapeRight = isEnable;
}


- (void)setNavigationBarHidden:(BOOL)hidden
{
    [self.navigationController setNavigationBarHidden:hidden];
}

- (void)setNavigationBarTintColor:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)setBackBarButtonOfNavigationBarWithTitle:(NSString *)title
{
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
    barItem.tag = [self getNewSenderTag];
    [self.navigationItem setBackBarButtonItem:barItem];
}

- (void)setLeftBarButtonOfNavigationBarWithTitle:(NSString*)title jsCallBack:(NSString*)jsCallBack
{
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonClickDispatchToWeb:)];
    barItem.tag = [self getNewSenderTag];
    self.navigationItem.leftBarButtonItem = barItem;

    [self registerJSCallBackToSender:barItem.tag jsCallBack:jsCallBack];
}

- (void)setLeftBarButtonOfNavigationBarWithImageNamed:(NSString*)imageName jsCallBack:(NSString*)jsCallBack
{
    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName] style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonClickDispatchToWeb:)];
    barItem.tag = [self getNewSenderTag];
    self.navigationItem.leftBarButtonItem = barItem;
    
    [self registerJSCallBackToSender:barItem.tag jsCallBack:jsCallBack];
}

- (void)setLeftBarButtonOfNavigationBarWithImageResId:(NSString*)imageResId jsCallBack:(NSString*)jsCallBack
{
    NSString* filePath = [[WebManager webController].resourceFileManager getResourceFilePath:imageResId];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];

    UIBarButtonItem* barItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:self action:@selector(barButtonClickDispatchToWeb:)];
    barItem.tag = [self getNewSenderTag];
    self.navigationItem.leftBarButtonItem = barItem;

    [self registerJSCallBackToSender:barItem.tag jsCallBack:jsCallBack];
}

- (void)barButtonClickDispatchToWeb:(id)sender
{
    NSString* jsCallBack = [self getJSCallBackWithSenderTag:((UIBarItem*)sender).tag];
    if(jsCallBack != nil && jsCallBack.length > 0)
    {
        [self callJavaScript:jsCallBack params:nil];
    }
}


- (void)registerJSCallBackToViewEvent:(NSString *)eventName jsCallBack:(NSString *)jsCallBack
{
    //支持的事件名: viewDidLoad,viewDidUnload, viewWillUnload, viewWillAppear, viewWillDisappear, viewDidAppear, viewDidDisappear
    if(eventName == nil || jsCallBack == nil)
    {
        return;
    }
    
    if([_viewEventNameToJSCallBackMapping objectForKey:eventName] == nil)
    {
        SSLogDebug(@"eventName:%@ jsCallBack:%@", eventName, jsCallBack);
        [_viewEventNameToJSCallBackMapping setObject:jsCallBack forKey:eventName];
    }
    
}

#pragma mark - ViewController transition
- (CommonWebViewController*)createPageView:(NSString*)pageName
{
    CommonWebViewController* vc = [[CommonWebViewController alloc] init];
    vc.localPage = pageName;
    
    return vc;
}

- (id)createPageView:(NSString *)pageName commonWebViewControllerClassName:(NSString *)commonWebViewControllerClassName
{
    Class cls = NSClassFromString(commonWebViewControllerClassName);
    id webVC = [[cls alloc] init];
    ((CommonWebViewController*)webVC).localPage = pageName;
    
    return webVC;
}

- (id)createPageView:(NSString *)pageName commonWebViewControllerClassName:(NSString *)commonWebViewControllerClassName viewServiceClassName:(NSString *)viewServiceClassName
{
    Class cls = NSClassFromString(commonWebViewControllerClassName);
    id webVC = [[cls alloc] initWithViewServiceName:viewServiceClassName];
    ((CommonWebViewController*)webVC).localPage = pageName;
    
    return webVC;
}

- (void)pushPageView:(CommonWebViewController *)pageView setIntoNavigationAsRoot:(BOOL)setIntoNavigationAsRoot
{
    [self.navigationController pushViewController:pageView animated:YES];
}

- (void)pushPage:(NSString *)pageName
{
    CommonWebViewController* vc = [self createPageView:pageName];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popToRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)popToPage:(NSString *)pageName
{
    NSArray* vcArray = [self.navigationController viewControllers];
    UIViewController* vc = nil;
    
    for(NSInteger i = vcArray.count; i >= 0; i--)
    {
        vc = [vcArray objectAtIndex:i];
        if([vc isKindOfClass:[LocalWebViewController class]])
        {
            if([((LocalWebViewController*)vc).localPage isEqualToString:pageName])
            {
                break;
            }
        }
    }
    
    if(vc != nil)
    {
        [self.navigationController popToViewController:vc animated:YES];
    }
}

- (void)presentPageView:(CommonWebViewController *)pageView setIntoNavigationAsRoot:(BOOL)setIntoNavigationAsRoot
{
    if(setIntoNavigationAsRoot)
    {
        UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:pageView];
        [self presentModalViewController:navi animated:YES];
    }
    else
    {
        [self presentModalViewController:pageView animated:YES];
    }
}

- (void)presentPage:(NSString *)pageName setIntoNavigationAsRoot:(BOOL)setIntoNavigationAsRoot
{
    CommonWebViewController* vc = [self createPageView:pageName];
    
    [self presentPageView:vc setIntoNavigationAsRoot:setIntoNavigationAsRoot];
}

//- (void)dismissSelf
//{
//    [self dismissModalViewControllerAnimated:YES];
//}

- (void)dismissSelf:(BOOL)animated
{
    [self dismissModalViewControllerAnimated:animated];
}

- (void)enableScrollBar
{
    if(self.webView != nil)
    {
        [self.scrollViewOfWebView setBounces:YES];
        [self.scrollViewOfWebView setScrollEnabled:YES];
    }
}

- (void)disableScrollBar
{
    if(self.webView != nil)
    {
        [self.scrollViewOfWebView setBounces:NO];
        [self.scrollViewOfWebView setScrollEnabled:NO];
    }
}

@end
