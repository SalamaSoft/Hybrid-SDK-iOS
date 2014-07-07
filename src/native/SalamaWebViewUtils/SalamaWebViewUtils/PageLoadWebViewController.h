//
//  PageLoadWebViewController.h
//  SalamaWebViewUtils
//
//  Created by Liu XingGu on 12-10-7.
//
//

#import "CommonWebViewController.h"

#import "PageLoadingAnimationView.h"

@interface PageLoadWebViewController : CommonWebViewController<UIScrollViewDelegate>
{
    @protected
    PageLoadingAnimationView* _pageLoadingViewOnTop;
    CGRect _backViewOfPageLoadingViewOnTopRect;
    
    PageLoadingAnimationView* _pageLoadingViewOnBottom;
    CGRect _backViewOfPageLoadingViewOnBottomRect;
    
    float _webContentHeight;
    BOOL _isPageLoadingViewInited;
    
    NSString* _jsCallBackToDidDragToStartPageLoadingAnimationOnTop;
    NSString* _jsCallBackToDidDragToStartPageLoadingAnimationOnBottom;
}

/**
 * 是否隐藏上方装载动画栏
 */
@property (nonatomic, assign) BOOL isPageLoadingAnimationOnTopHidden;

/**
 * 是否隐藏下方装载动画栏
 */
@property (nonatomic, assign) BOOL isPageLoadingAnimationOnBottomHidden;

/**
 * 取得上方装载动画栏
 */
@property (nonatomic, readonly) PageLoadingAnimationView* pageLoadingViewOnTop;

/**
 * 取得下方装载动画栏
 */
@property (nonatomic, readonly) PageLoadingAnimationView* pageLoadingViewOnBottom;

/**
 * 注册绑定上方装载中动画开始事件至JavaScript回调函数
 */
- (void)registerJSCallBackToDidDragToStartPageLoadingAnimationOnTop:(NSString*)jsCallBack;

/**
 * 注册绑定下方装载中动画开始事件至JavaScript回调函数
 */
- (void)registerJSCallBackToDidDragToStartPageLoadingAnimationOnBottom:(NSString*)jsCallBack;

/**
 * 事件:用户拖拽操作触发上方的“下载中”动画
 */
- (void)didDragToStartPageLoadingAnimationOnTop;

/**
 * 事件:用户拖拽操作触发下方的“下载中”动画
 */
- (void)didDragToStartPageLoadingAnimationOnBottom;

/**
 * 开始上方的“下载中”动画
 */
- (void)startPageLoadingAnimationOnTop;

/**
 * 开始下方的“下载中”动画
 */
- (void)startPageLoadingAnimationOnBottom;

/**
 * 停止上方的“下载中”动画
 */
- (void)stopPageLoadingAnimationOnTop;

/**
 * 停止下方的“下载中”动画
 */
- (void)stopPageLoadingAnimationOnBottom;

/**
 * 更新下方下载中动画区域的位置
 * <BR>webView的内容区域高度变化后，需要更新下方下载中动画区域的位置
 */
-(void)updatePositionOfPageLodingViewOnBottom;

@end
