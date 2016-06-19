//
//  BaseWebViewController.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-10.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "BaseWebViewController.h"

#import "WebManager.h"
#import "SimpleMetoXML.h"
#import "SSLog.h"
#import "ViewService.h"

/********** alert view handler **********/
@implementation WebViewAlertViewDelegateHandler
@synthesize viewController;

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* jsCallBack = [self.viewController getJSCallBackWithSenderTag:alertView.tag];
    if(jsCallBack != nil && jsCallBack.length > 0)
    {
        [self.viewController callJavaScript:jsCallBack params:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%lld", (long long)buttonIndex], nil]];
    }
}

@end


@interface BaseWebViewController ()

- (void)initVars;

@end

@implementation BaseWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //SSLogDebug(@"initWithNibName()");
        [self initVars];
    }
    return self;
}

- (void)initVars
{
    _senderTagToJSCallBackMapping = [[NSMutableDictionary alloc] init];
    _senderTagSeed = 1999;
    
    _alertViewHandler = [[WebViewAlertViewDelegateHandler alloc] init];
    _alertViewHandler.viewController = self;
    
    
    _notificationNameToJSCallBackMapping = [[NSMutableDictionary alloc] init];
    
}

- (void)dealloc
{
    //
    [_senderTagToJSCallBackMapping removeAllObjects];
    _senderTagToJSCallBackMapping = nil;
    
    //
    _alertViewHandler.viewController = nil;
    _alertViewHandler = nil;
    
    //
    NSEnumerator* keyEnum = [_notificationNameToJSCallBackMapping keyEnumerator];
    NSString* notificationName = nil;
    while (true) {
        notificationName = [keyEnum nextObject];
        
        if(notificationName == nil)
        {
            break;
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
    }
    
    //
    [_notificationNameToJSCallBackMapping removeAllObjects];
    _notificationNameToJSCallBackMapping = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - base method about event

- (int)getNewSenderTag
{
    @synchronized(self)
    {
        _senderTagSeed++;
        
        return _senderTagSeed;
    }
}


- (void)registerJSCallBackToSender:(NSInteger)senderTag jsCallBack:(NSString *)jsCallBack
{
    [_senderTagToJSCallBackMapping setObject:jsCallBack forKey:[NSNumber numberWithInteger:senderTag]];
}

- (NSString *)getJSCallBackWithSenderTag:(NSInteger)senderTag
{
    return [_senderTagToJSCallBackMapping objectForKey:[NSNumber numberWithInteger:senderTag]];
}

- (void)notifyToJSCallBack:(NSNotification *)notification
{
    __block NSString* jsCallBack = [_notificationNameToJSCallBackMapping objectForKey:notification.name];
    
    //id userInfoObj = [[notification.userInfo objectEnumerator] nextObject];
    id userInfoObj = [notification.userInfo objectForKey:NOTIFICATION_FOR_JAVASCRIPT_USER_INFO_RESULT_NAME];
    
    __block NSArray* jsParams = nil;
    
    SSLogDebug(@"notification.name:%@ jsCallBack:%@", notification.name, jsCallBack);
    
    if(userInfoObj != nil)
    {
        SSLogDebug(@"class of userInfoObj:%@", NSStringFromClass(((NSObject*)userInfoObj).class));
        
        if([userInfoObj isKindOfClass:[NSString class]])
        {
            SSLogDebug(@"jsParam:%@", userInfoObj);
            jsParams = [NSArray arrayWithObjects:userInfoObj, nil];
        }
        else
        {
            NSString* jsParamXml = [SimpleMetoXML objectToString:userInfoObj];
            SSLogDebug(@"jsParam:%@", jsParamXml);
            jsParams = [NSArray arrayWithObjects:jsParamXml, nil];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callJavaScript:jsCallBack params:jsParams];
        
        jsCallBack = nil;
        jsParams = nil;
    });
}


#pragma mark - setting for JavaScript
- (void)registerJSCallBackToNotification:(NSString *)notificationName jsCallBack:(NSString *)jsCallBack
{
    if(notificationName == nil || jsCallBack == nil)
    {
        return;
    }
    
    if([_notificationNameToJSCallBackMapping objectForKey:notificationName] == nil)
    {
        SSLogDebug(@"notificationName:%@ jsCallBack:%@", notificationName, jsCallBack);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyToJSCallBack:) name:notificationName object:nil];
        
        [_notificationNameToJSCallBackMapping setObject:jsCallBack forKey:notificationName];
    }
}

#pragma mark - UI operation helper
- (void)showAlert:(NSString*)title message:(NSString*)message buttonTitleList:(NSArray*)buttonTitleList  jsCallBack:(NSString*)jsCallBack
{
    UIAlertView* alert = nil;
    
    id alertDelegate = nil;
    if(jsCallBack != nil && jsCallBack.length > 0)
    {
        alertDelegate = _alertViewHandler;
    }
    
    if(buttonTitleList == nil || buttonTitleList.count == 0)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:nil otherButtonTitles:nil];
    }
    else if(buttonTitleList.count == 1)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:[buttonTitleList objectAtIndex:0] otherButtonTitles:nil];
    }
    else if(buttonTitleList.count == 2)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:[buttonTitleList objectAtIndex:0] otherButtonTitles:[buttonTitleList objectAtIndex:1], nil];
    }
    else if(buttonTitleList.count == 3)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:[buttonTitleList objectAtIndex:0] otherButtonTitles:[buttonTitleList objectAtIndex:1], [buttonTitleList objectAtIndex:2], nil];
    }
    else if(buttonTitleList.count == 4)
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:[buttonTitleList objectAtIndex:0] otherButtonTitles:[buttonTitleList objectAtIndex:1], [buttonTitleList objectAtIndex:2], [buttonTitleList objectAtIndex:3], nil];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:alertDelegate cancelButtonTitle:[buttonTitleList objectAtIndex:0] otherButtonTitles:[buttonTitleList objectAtIndex:1], [buttonTitleList objectAtIndex:2], [buttonTitleList objectAtIndex:3], [buttonTitleList objectAtIndex:4], nil];
    }
    
    if(jsCallBack != nil && jsCallBack.length > 0)
    {
        alert.tag = [self getNewSenderTag];
        [self registerJSCallBackToSender:alert.tag jsCallBack:jsCallBack];
    }
    
    [alert show];
}

- (void)startWaitingSpinnerAnimating:(int)spinnerUIStyle
{
    if(_spinnerForWaiting == nil)
    {
        //spinner
        _spinnerForWaiting = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:spinnerUIStyle];
        _spinnerForWaiting.hidesWhenStopped = YES;
        
        [self.view addSubview:_spinnerForWaiting];
        _spinnerForWaiting.center = self.view.center;
    }
    else
    {
        _spinnerForWaiting.activityIndicatorViewStyle = spinnerUIStyle;
    }
    
    [_spinnerForWaiting startAnimating];
}

- (void)stopWaitingSpinnerAnimating
{
    if(_spinnerForWaiting != nil)
    {
        [_spinnerForWaiting stopAnimating];
    }
}

@end
