//
//  ViewService.h
//  EFKLife
//
//  Created by Liu XingGu on 12-11-16.
//  Copyright (c) 2012年 salama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LocalWebViewController.h"

@interface ViewService : NSObject

/**
 * 当前View
 */
@property (nonatomic, unsafe_unretained) LocalWebViewController* thisView;

/**
 * events of UIViewController
 */
- (void)viewDidLoad;

/**
 * events of UIViewController
 */
- (void)viewDidUnload;

/**
 * events of UIViewController
 */
- (void)viewWillUnload;

/**
 * events of UIViewController
 */
- (void)viewWillAppear;

/**
 * events of UIViewController
 */
- (void)viewWillDisappear;

/**
 * events of UIViewController
 */
- (void)viewDidAppear;

/**
 * events of UIViewController
 */
- (void)viewDidDisappear;

@end
