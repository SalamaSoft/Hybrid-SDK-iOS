//
//  LocalWebViewController.m
//  Salama
//
//  Created by XingGu Liu on 12-5-19.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#import "LocalWebViewController.h"

#import "WebManager.h"
#import "ViewService.h"

@interface LocalWebViewController()

- (void)createObjs;

@end

@implementation LocalWebViewController

//#define USER_AGENT_MOBILE_APP @"SalamaMobileApp"

//@synthesize webView;

@synthesize localPage;

@synthesize scrollViewOfWebView = _scrollViewOfWebView;

//@synthesize thisViewServiceClassName = _thisViewServiceClassName;
@synthesize thisViewService = _thisViewService;

-(UIWebView *)webView
{
    return _webView;
}

-(void)setWebView:(UIWebView *)value
{
//    if(_webView != nil)
//    {
//        _webView.delegate = nil;
//        _webView = nil;
//    }
    
    _webView = nil;
    _scrollViewOfWebView = nil;
    
    _webView = value;
    
    if(_webView == nil)
    {
        return;
    }
    
    _webView.delegate = self;
    _scrollViewOfWebView = (UIScrollView *)[[_webView subviews] objectAtIndex:0];
    
    /*
    if(!_viewAppearedFlg)
    {
        [self loadLocalPage:localPage];
    }
    _viewAppearedFlg = YES;
    */
}

- (NSString*)thisViewServiceClassName
{
    return _thisViewServiceClassName;
}

- (void)setThisViewServiceClassName:(NSString *)name
{
    //this viewService
    if(_thisViewService == nil)
    {
        _thisViewServiceClassName = [name copy];

        Class thisViewServiceCls = NSClassFromString(_thisViewServiceClassName);
        _thisViewService = [[thisViewServiceCls alloc] init];
        ((ViewService*)_thisViewService).thisView = self;

        SSLogDebug(@"init viewService:%@", name);
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self createObjs];
    }
    return self;
}

- (id)initWithViewServiceName:(NSString *)viewServiceClassName
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self createObjs];
        
        [self setThisViewServiceClassName:viewServiceClassName];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        [self createObjs];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self createObjs];
    }
    return self;
}

- (void)createObjs
{
    //nativeServiceQueue = dispatch_queue_create("invoke.nativeService", NULL);
    _webVariableStackForScopePage = [[NSMutableDictionary alloc] init];
    _webVariableStackForScopeTemp = [[NSMutableDictionary alloc] init];
    
    _transitionParams = [[NSMutableDictionary alloc] init];
}

- (void)dealloc
{
    //dispatch_release(nativeServiceQueue);
    [_webVariableStackForScopePage removeAllObjects];

    //transition params
    [_transitionParams removeAllObjects];
    _transitionParams = nil;

    _webView = nil;
}

- (void)viewDidLoad
{
    //NSLog(@"viewDidLoad:%@", self.title);
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    //[WebManager setThisView:self webView:webView];
    //webView.delegate = self;

    //_viewAppearedFlg = NO;
    
}

- (void)viewDidUnload
{
    //NSLog(@"viewDidUnload:%@", self.title);

    if(_webView != nil)
    {
        _webView.delegate = nil;
        _webView = nil;
    }

    localPage = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
    if(!_viewAppearedFlg)
    {
        [self loadLocalPage:localPage];
        
        _viewAppearedFlg = YES;
    }
    */
    if(!_webViewLoadedFlg)
    {
        [self loadLocalPage:localPage];
    }

}

-(void)loadLocalPage:(NSString*)relativeUrl
{
    _webViewLoadedFlg = YES;
    //NSLog(@"loadLocalPage:%@", relativeUrl);
    localPage = relativeUrl;
    [[WebManager webController] loadLocalPage:relativeUrl webView:_webView];
}

//handle the web view delegate
-(BOOL) webView:(UIWebView *)sender shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* urlPath = request.URL.absoluteString;
    /*  debug
     NSLog(@"shouldStartLoadWithRequest navigationType:%d", navigationType);
     
     NSLog(@"shouldStartLoadWithRequest mainDocumentURL:%@", request.mainDocumentURL);
     NSLog(@"shouldStartLoadWithRequest URL:%@", request.URL);
     
     NSLog(@"shouldStartLoadWithRequest URL.absoluteString:%@", request.URL.absoluteString);
     NSLog(@"shouldStartLoadWithRequest URL.fragment:%@", request.URL.fragment);
     NSLog(@"shouldStartLoadWithRequest URL.host:%@", request.URL.host);
     NSLog(@"shouldStartLoadWithRequest URL.lastPathComponent:%@", request.URL.lastPathComponent);
     NSLog(@"shouldStartLoadWithRequest URL.parameterString:%@", request.URL.parameterString);
     NSLog(@"shouldStartLoadWithRequest URL.password:%@", request.URL.password);
     NSLog(@"shouldStartLoadWithRequest URL.path:%@", request.URL.path);
     NSLog(@"shouldStartLoadWithRequest URL.port:%@", request.URL.port);
     NSLog(@"shouldStartLoadWithRequest URL.query:%@", request.URL.query);
     NSLog(@"shouldStartLoadWithRequest URL.relativePath:%@", request.URL.relativePath);
     NSLog(@"shouldStartLoadWithRequest URL.relativeString:%@", request.URL.relativeString);
     NSLog(@"shouldStartLoadWithRequest URL.resourceSpecifier:%@", request.URL.resourceSpecifier);
     NSLog(@"shouldStartLoadWithRequest URL.scheme:%@", request.URL.scheme);
     NSLog(@"shouldStartLoadWithRequest URL.user:%@", request.URL.user);
     */
    
    SSLogDebug(@"shouldStartLoadWithRequest urlPath:%@", urlPath);
    
    /*
    if(![WebManager webController].isUserAgentInited)
    {
        //NSString* curUserAgent = [request valueForHTTPHeaderField:@"User-Agent"];
        NSString* curUserAgent = [sender stringByEvaluatingJavaScriptFromString:@""];
        SSLogDebug(@"curUserAgent:%@", curUserAgent);

        //Init user agent
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@ SalamaMobileApp", curUserAgent], @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        
        [WebManager webController].isUserAgentInited = YES;
    }
    */
    /*
     //set user-agent
     NSMutableURLRequest *req = (NSMutableURLRequest *)request;
     if ([req respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
     [req setValue:[NSString stringWithFormat:@"%@ %@", [req valueForHTTPHeaderField:@"User-Agent"], USER_AGENT_MOBILE_APP] forHTTPHeaderField:@"User_Agent"];
     }
     */
    
    /* deprecated
    id msg = [NativeService parseNativeServiceCmd:urlPath];
    if(msg != nil)
    {
        [[WebManager webController] invokeNativeService:msg webView:sender thisView:self];
        return NO;
    }
    else
    {
        return YES;
    }
    */
    
    return [[WebManager webController] handleUrlLoadingEvent:urlPath webView:sender thisView:self];
}

-(void)log:(NSString*)msg
{
    SSLogDebug(@"%@ %@", self.localPage, msg);
}

-(NSString*)callJavaScript:(NSString*)functionName params:(NSArray*)params
{
    NSMutableString* script = [[NSMutableString alloc] init];
    
    [script appendFormat:@"%@(", functionName];
    
    //params
    NSString* param;
    if(params != nil)
    {
        for(int i = 0; i < params.count; i++)
        {
            if(i > 0)
            {
                [script appendString:@","];
            }

            param = [params objectAtIndex:i];
            char* cFuncParamStr = [WebController encodeToScriptStringValue:[param UTF8String]];
            
            [script appendFormat:@"'%@'", [NSString stringWithUTF8String:cFuncParamStr]];
            
            free(cFuncParamStr);
            
        }
    }
    
    [script appendString:@")"];
    
    SSLogDebug(@"callJavaScript script:%@", script);
    
    NSString* result = [_webView stringByEvaluatingJavaScriptFromString:script];
    
    [self didCallJavascript:result];
    
    return result;
}

-(void)didCallJavascript:(NSString *)returnValue
{
}

#pragma mark - Implementation of WebVariableStack

- (void)clearVariablesOfAllScope
{
    [_webVariableStackForScopePage removeAllObjects];
    [_webVariableStackForScopeTemp removeAllObjects];
}

- (void)clearVariablesOfScope:(WebVariableStackScope)scope
{
    if(scope == WebVariableStackScopeTemp)
    {
        [_webVariableStackForScopeTemp removeAllObjects];
    } else if(scope == WebVariableStackScopePage)
    {
        [_webVariableStackForScopePage removeAllObjects];
    }
}

- (void)setVariable:(id)value name:(NSString *)name scope:(WebVariableStackScope)scope
{
    if(scope == WebVariableStackScopeTemp)
    {
        [_webVariableStackForScopeTemp setObject:value forKey:name];
    } else if(scope == WebVariableStackScopePage)
    {
        [_webVariableStackForScopePage setObject:value forKey:name];
    }
}

- (id)getVariable:(NSString *)name scope:(WebVariableStackScope)scope
{
    if(scope == WebVariableStackScopeTemp)
    {
        return [_webVariableStackForScopeTemp objectForKey:name];
    } 
    else if(scope == WebVariableStackScopePage)
    {
        return [_webVariableStackForScopePage objectForKey:name];
    }
    else 
    {
        return nil;
    }
}

- (void)setTransitionParam:(id)paramValue paramName:(NSString *)paramName
{
    [_transitionParams setObject:paramValue forKey:paramName];
}

- (id)getTransitionParamByName:(NSString *)paramName
{
    return [_transitionParams objectForKey:paramName];
}

-(void)removeVariable:(NSString *)name scope:(WebVariableStackScope)scope
{
    if(scope == WebVariableStackScopeTemp)
    {
        [_webVariableStackForScopeTemp removeObjectForKey:name];
    } 
    else if(scope == WebVariableStackScopePage)
    {
        [_webVariableStackForScopePage removeObjectForKey:name];
    }
}

- (void)setSessionValueWithName:(NSString *)name value:(NSString *)value
{
    [[WebManager webController] setSessionValueWithName:name value:value];
}

- (void)removeSessionValueWithName:(NSString *)name
{
    [[WebManager webController] removeSessionValueWithName:name];
}

- (NSString *)getSessionValueWithName:(NSString *)name
{
    return [[WebManager webController] getSessionValueWithName:name];
}

@end

