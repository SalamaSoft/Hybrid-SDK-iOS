//
//  EasyTabBarController.m
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-7.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import "EasyTabBarController.h"

@interface EasyTabBarController ()

- (void)initObjs;
- (void)initTabBarController;

- (void) showTabContentViewController: (UIViewController*) content;
- (void) hideTabContentViewController: (UIViewController*) content;

@end

#define DEFAULT_TAB_BAR_HEIGHT 49

@implementation EasyTabBarController

@synthesize tabBarFrame = _tabBarFrame;
@synthesize tabContentFrame = _tabContentFrame;
@synthesize tabBarView = _tabBarView;
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

/*
- (id)init
{
    if(self = [super init])
    {
        [self initObjs];
    }
    
    return self;
}
*/

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
    
    NSLog(@"EasyTabBarController didReceiveMemoryWarning()");
}

- (void)initObjs
{
    _viewControllers = [[NSMutableArray alloc] init];
    
    _tabBarFrame = CGRectMake(0, 0, 0, 0);
    _tabContentFrame = CGRectMake(0, 0, 0, 0);
    
    _selectedTabIndex = 0;
    
    _viewInited = NO;
}

- (void)initTabBarController
{
    if(_tabBarFrame.size.height == 0)
    {
        _tabBarFrame = CGRectMake(0, self.view.bounds.size.height - DEFAULT_TAB_BAR_HEIGHT, self.view.bounds.size.width, DEFAULT_TAB_BAR_HEIGHT);
        
        _tabContentFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - DEFAULT_TAB_BAR_HEIGHT);
    }
    
    _tabBarView.frame = _tabBarFrame;
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

- (BOOL)isTabBarHidden
{
    return _tabBarView.hidden;
}

- (void)setTabBarHidden:(BOOL)hidden
{
    _tabBarView.hidden = hidden;
}


@end
