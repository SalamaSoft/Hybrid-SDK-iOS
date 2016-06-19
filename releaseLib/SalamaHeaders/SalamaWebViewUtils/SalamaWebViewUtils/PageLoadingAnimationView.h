//
//  PageLoadingAnimationView.h
//  SalamaWebViewUtils
//
//  Created by Liu XingGu on 12-10-7.
//
//

#import <UIKit/UIKit.h>

typedef enum PageLoadingAnimationViewDisplayStatus{
    PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange = 0,PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange, PageLoadingAnimationViewDisplayStatusWhenOnLoading
} PageLoadingAnimationViewDisplayStatus;

typedef enum PageLoadingAnimationViewContentVAlign{
    PageLoadingAnimationViewContentVAlignTop = 0,
    PageLoadingAnimationViewContentVAlignCenter,
    PageLoadingAnimationViewContentVAlignBottom
} PageLoadingAnimationViewContentVAlign;

@interface PageLoadingAnimationView : UIView
{
    @private
    UIActivityIndicatorView* _spinner;
    UILabel* _titleLabel;
    
    CGRect _spinnerRect;
    PageLoadingAnimationViewDisplayStatus _displayStatus;
    
    PageLoadingAnimationViewContentVAlign _contentVAlign;
    
    NSString* _titleWhenDraggingBeforeLoadingPreparedRange;
    NSString* _titleWhenDraggingInLoadingRange;
    NSString* _titleWhenOnLoading;
    //float _titleLabelHeight;
}

/**
 * 初始状态标题
 */
@property (nonatomic, retain) NSString* titleWhenDraggingBeforeLoadingPreparedRange;

/**
 * 拖拽至准备装载状态标题
 */
@property (nonatomic, retain) NSString* titleWhenDraggingInLoadingRange;

/**
 * 放开时装载中状态标题
 */
@property (nonatomic, retain) NSString* titleWhenOnLoading;

/**
 * 标题高度
 */
@property (nonatomic, assign) float titleLabelHeight;

/**
 * 初始化
 * @param frame 矩形区域
 * @param contentVAlign 内容纵向对齐方式
 */
-(id)initWithFrame:(CGRect)frame contentVAlign:(PageLoadingAnimationViewContentVAlign)contentVAlign;

/**
 * 返回显示状态
 */
-(PageLoadingAnimationViewDisplayStatus)displayStatus;

/**
 * 更新显示状态
 */
-(void)updateDisplayStatus:(PageLoadingAnimationViewDisplayStatus)displayStatus;


@end
