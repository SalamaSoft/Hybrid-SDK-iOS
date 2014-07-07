//
//  ViewService.m
//  EFKLife
//
//  Created by Liu XingGu on 12-11-16.
//  Copyright (c) 2012年 salama. All rights reserved.
//

#import "ViewService.h"
#import "SSLog.h"
#import "CommonWebViewController.h"

@implementation ViewService

@synthesize thisView;

- (void)viewDidLoad
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}

- (void)viewDidUnload
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}

- (void)viewWillUnload
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}

- (void)viewWillAppear
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}

- (void)viewWillDisappear
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}

- (void)viewDidAppear
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}

- (void)viewDidDisappear
{
    SSLogDebug(@"localPage:%@", ((CommonWebViewController*)self.thisView).localPage);
}


@end
