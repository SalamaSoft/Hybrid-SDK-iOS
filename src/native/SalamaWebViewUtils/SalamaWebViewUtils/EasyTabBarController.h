//
//  EasyTabBarController.h
//  DeveloperGroup
//
//  Created by Liu Xinggu on 13-8-7.
//  Copyright (c) 2013年 Salama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EasyTabBarController : UIViewController
{
    @private
    UIView* _tabBarView;
    NSMutableArray* _viewControllers;

    CGRect _tabBarFrame;
    CGRect _tabContentFrame;
    
    int _selectedTabIndex;
    
    BOOL _viewInited;
}

/**
 * tab content frame
 */
@property(nonatomic, assign) CGRect tabContentFrame;

/**
 * tab bar frame
 */
@property(nonatomic, assign) CGRect tabBarFrame;

/**
 * tab content的ViewController列表(NSArray<UIViewController>)
 */
@property(nonatomic, readonly) NSMutableArray* viewControllers;

/**
 * tab bar隐藏状态
 * @return YES:隐藏 NO:显示
 */
- (BOOL)isTabBarHidden;

/**
 * 设置tab bar隐藏
 * @param hidden YES:隐藏 NO:显示
 */
- (void)setTabBarHidden:(BOOL)hidden;

/**
 * 设置tab bar view
 * @param tabBarView 显示tab bar用的UIView
 */
@property(nonatomic, retain) UIView* tabBarView;

/**
 * 设置当前tab的索引
 * @param tabIndex tab的索引(0开始)
 */
- (void)setSelectedTabIndex:(int)tabIndex;

/**
 * 取得当前tab的索引(0开始)
 */
- (int)getSelectedTabIndex;

@end
