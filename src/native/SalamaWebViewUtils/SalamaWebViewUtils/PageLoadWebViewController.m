//
//  PageLoadWebViewController.m
//  SalamaWebViewUtils
//
//  Created by Liu XingGu on 12-10-7.
//
//

#import "PageLoadWebViewController.h"

#define PAGE_LOADING_VIEW_BACKVIEW_HEIGHT 280

@interface PageLoadWebViewController (PrivateMethod)

-(void)initScrollView;

-(void)updateDisplayStatusOfPageLoadingViewOnTop:(PageLoadingAnimationViewDisplayStatus)displayStatus;

-(void)updateDisplayStatusOfPageLoadingViewOnBottom:(PageLoadingAnimationViewDisplayStatus)displayStatus;

@end

@implementation PageLoadWebViewController

@synthesize pageLoadingViewOnTop = _pageLoadingViewOnTop;
@synthesize pageLoadingViewOnBottom = _pageLoadingViewOnBottom;

- (BOOL)isPageLoadingAnimationOnTopHidden
{
    return _pageLoadingViewOnTop.isHidden;
}

- (void)setIsPageLoadingAnimationOnTopHidden:(BOOL)isHidden
{
    [_pageLoadingViewOnTop setHidden:isHidden];
}

- (BOOL)isPageLoadingAnimationOnBottomHidden
{
    return _pageLoadingViewOnBottom.isHidden;
}

- (void)setIsPageLoadingAnimationOnBottomHidden:(BOOL)isHidden
{
    [_pageLoadingViewOnBottom setHidden:isHidden];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.scrollViewOfWebView setBounces:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initScrollView];
}

- (void)registerJSCallBackToDidDragToStartPageLoadingAnimationOnTop:(NSString *)jsCallBack
{
    _jsCallBackToDidDragToStartPageLoadingAnimationOnTop = [jsCallBack copy];
}

- (void)registerJSCallBackToDidDragToStartPageLoadingAnimationOnBottom:(NSString *)jsCallBack
{
    _jsCallBackToDidDragToStartPageLoadingAnimationOnBottom = [jsCallBack copy];
}

- (void)initScrollView
{
    if(_isPageLoadingViewInited)
    {
        return;
    }
    
    if(_scrollViewOfWebView == nil)
    {
        return;
    }
    
    _isPageLoadingViewInited = YES;
    
    
    //init page load view -------------------------------------------------------------------------
    _scrollViewOfWebView.delegate = self;
    
    _webContentHeight = [self getWebContentHeight];
    
    //TOP ---------------------------------
    _backViewOfPageLoadingViewOnTopRect = CGRectMake(0, 0 - PAGE_LOADING_VIEW_BACKVIEW_HEIGHT, _scrollViewOfWebView.contentSize.width, PAGE_LOADING_VIEW_BACKVIEW_HEIGHT);
    
    _pageLoadingViewOnTop = [[PageLoadingAnimationView alloc] initWithFrame:_backViewOfPageLoadingViewOnTopRect contentVAlign:PageLoadingAnimationViewContentVAlignBottom];
    
    [_pageLoadingViewOnTop updateDisplayStatus:PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange];
    
    [_scrollViewOfWebView addSubview:_pageLoadingViewOnTop];
    
    //BOTTOM ------------------------------
    int pageLoadingOfBottomY = _webContentHeight;
    if(pageLoadingOfBottomY == 0)
    {
        pageLoadingOfBottomY = _scrollViewOfWebView.contentSize.height;
    }
    _backViewOfPageLoadingViewOnBottomRect = CGRectMake(0, pageLoadingOfBottomY, _scrollViewOfWebView.contentSize.width, PAGE_LOADING_VIEW_BACKVIEW_HEIGHT);

    _pageLoadingViewOnBottom = [[PageLoadingAnimationView alloc] initWithFrame:_backViewOfPageLoadingViewOnBottomRect contentVAlign:PageLoadingAnimationViewContentVAlignTop];
    
    [_pageLoadingViewOnBottom updateDisplayStatus:PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange];
    
    [_scrollViewOfWebView addSubview:_pageLoadingViewOnBottom];
    
    if(self.isPageLoadingAnimationOnTopHidden)
    {
        [_pageLoadingViewOnTop setHidden:YES];
    }
    
    if(self.isPageLoadingAnimationOnBottomHidden)
    {
        [_pageLoadingViewOnBottom setHidden:YES];
    }
    
}

- (void)didCallJavascript
{
    [self updatePositionOfPageLodingViewOnBottom];
}

/**
 事件:用户拖拽操作触发上方的“下载中”动画
 **/
- (void)didDragToStartPageLoadingAnimationOnTop
{
    if(_jsCallBackToDidDragToStartPageLoadingAnimationOnTop != nil)
    {
        [self callJavaScript:_jsCallBackToDidDragToStartPageLoadingAnimationOnTop params:nil];
    }
}

/**
 事件:用户拖拽操作触发下方的“下载中”动画
 **/
- (void)didDragToStartPageLoadingAnimationOnBottom
{
    if(_jsCallBackToDidDragToStartPageLoadingAnimationOnBottom)
    {
        [self callJavaScript:_jsCallBackToDidDragToStartPageLoadingAnimationOnBottom params:nil];
    }
}

/**
 开始上方的“下载中”动画
 **/
- (void)startPageLoadingAnimationOnTop
{
    [self updateDisplayStatusOfPageLoadingViewOnTop:PageLoadingAnimationViewDisplayStatusWhenOnLoading];
}

- (void)stopPageLoadingAnimationOnTop
{
    [self updateDisplayStatusOfPageLoadingViewOnTop:PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange];
}

- (void)startPageLoadingAnimationOnBottom
{
    [self updateDisplayStatusOfPageLoadingViewOnBottom:PageLoadingAnimationViewDisplayStatusWhenOnLoading];
}

- (void)stopPageLoadingAnimationOnBottom
{
    [self updateDisplayStatusOfPageLoadingViewOnBottom:PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange];
}

- (void)updateDisplayStatusOfPageLoadingViewOnTop:(PageLoadingAnimationViewDisplayStatus)displayStatus
{
    if(!_pageLoadingViewOnTop.isHidden)
    {
        if(_pageLoadingViewOnTop.displayStatus != displayStatus)
        {
            [_pageLoadingViewOnTop updateDisplayStatus:displayStatus];
            
            if (displayStatus == PageLoadingAnimationViewDisplayStatusWhenOnLoading)
            {
                //show loading animation area
                _scrollViewOfWebView.contentInset = UIEdgeInsetsMake(_pageLoadingViewOnTop.titleLabelHeight, 0, 0, 0);
                _scrollViewOfWebView.contentOffset = CGPointMake(0, 0 - _pageLoadingViewOnTop.titleLabelHeight);
            }
            else
            {
                //hide loading animation area
                _scrollViewOfWebView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                _scrollViewOfWebView.contentOffset = CGPointMake(0, 0);
            }
        }
    }
}

- (void)updateDisplayStatusOfPageLoadingViewOnBottom:(PageLoadingAnimationViewDisplayStatus)displayStatus
{
    if(!_pageLoadingViewOnBottom.isHidden)
    {
        _webContentHeight = [self getWebContentHeight];
        _backViewOfPageLoadingViewOnBottomRect = CGRectMake(0, _webContentHeight, _scrollViewOfWebView.contentSize.width, PAGE_LOADING_VIEW_BACKVIEW_HEIGHT);
        _pageLoadingViewOnBottom.frame = _backViewOfPageLoadingViewOnBottomRect;
        
        if(_pageLoadingViewOnBottom.displayStatus != displayStatus)
        {
            [_pageLoadingViewOnBottom updateDisplayStatus:displayStatus];
            
            if (displayStatus == PageLoadingAnimationViewDisplayStatusWhenOnLoading)
            {
                _scrollViewOfWebView.contentInset = UIEdgeInsetsMake(0, 0, _pageLoadingViewOnBottom.titleLabelHeight, 0);
            }
            else
            {
                _scrollViewOfWebView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float y = scrollView.contentOffset.y;
    float top = y + scrollView.frame.size.height;
    
    if(scrollView.dragging)
    {
        if(y < 0 && !_pageLoadingViewOnTop.isHidden)
        {
            if(_pageLoadingViewOnTop.displayStatus == PageLoadingAnimationViewDisplayStatusWhenOnLoading)
            {
                return;
            }
            
            float edgeY = 0 - _pageLoadingViewOnTop.titleLabelHeight;
            if(y < edgeY)
            {
                if(_pageLoadingViewOnTop.displayStatus != PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange)
                {
                    [_pageLoadingViewOnTop updateDisplayStatus:PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange];
                }
            }
            else
            {
                if(_pageLoadingViewOnTop.displayStatus != PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange)
                {
                    [_pageLoadingViewOnTop updateDisplayStatus:PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange];
                }
            }
        }
        else if (top > _webContentHeight && !_pageLoadingViewOnBottom.isHidden)
        {
            if(self.pageLoadingViewOnBottom.displayStatus == PageLoadingAnimationViewDisplayStatusWhenOnLoading)
            {
                return;
            }
            
            float edgeY = _webContentHeight + _pageLoadingViewOnTop.titleLabelHeight;
            if(top > edgeY)
            {
                if(_pageLoadingViewOnBottom.displayStatus != PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange)
                {
                    [_pageLoadingViewOnBottom updateDisplayStatus:PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange];
                }
            }
            else
            {
                if(_pageLoadingViewOnBottom.displayStatus != PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange)
                {
                    [_pageLoadingViewOnBottom updateDisplayStatus:PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!_pageLoadingViewOnTop.isHidden)
    {
        if(_pageLoadingViewOnTop.displayStatus == PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange)
        {
            [self updateDisplayStatusOfPageLoadingViewOnTop:PageLoadingAnimationViewDisplayStatusWhenOnLoading];
            
            [self didDragToStartPageLoadingAnimationOnTop];
        }
    }
    if(!_pageLoadingViewOnBottom.isHidden)
    {
        if(_pageLoadingViewOnBottom.displayStatus == PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange)
        {
            [self updateDisplayStatusOfPageLoadingViewOnBottom:PageLoadingAnimationViewDisplayStatusWhenOnLoading];
            
            [self didDragToStartPageLoadingAnimationOnBottom];
        }
    }
}

-(void)updatePositionOfPageLodingViewOnBottom
{
    _webContentHeight = [self getWebContentHeight];
    _backViewOfPageLoadingViewOnBottomRect = CGRectMake(0, _webContentHeight, _scrollViewOfWebView.contentSize.width, PAGE_LOADING_VIEW_BACKVIEW_HEIGHT);
    _pageLoadingViewOnBottom.frame = _backViewOfPageLoadingViewOnBottomRect;
}

@end
