//
//  PageLoadingAnimationView.m
//  SalamaWebViewUtils
//
//  Created by Liu XingGu on 12-10-7.
//
//

#import "PageLoadingAnimationView.h"

#define TITLE_LABEL_DEFAULT_HEIGHT 44

#define DefaultTitleWhenDraggingBeforeLoadingPreparedRange @"drag to download more"
#define DefaultTitleWhenDraggingInLoadingRange @"drop to start downloading"
#define DefaultTitleWhenOnLoading @"downloading"

@interface PageLoadingAnimationView(PrivateMethod)

-(void)initSubViews:(CGRect)frame;

@end

@implementation PageLoadingAnimationView

-(float)titleLabelHeight
{
    return _titleLabel.frame.size.height;
}

-(void)setTitleLabelHeight:(float)height
{
    if(_contentVAlign == PageLoadingAnimationViewContentVAlignBottom)
    {
        CGRect titleLabelRect = CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height);
        [_titleLabel setFrame:titleLabelRect];
    }
    else if (_contentVAlign == PageLoadingAnimationViewContentVAlignTop)
    {
        CGRect titleLabelRect = CGRectMake(0, 0, self.frame.size.width, height);
        [_titleLabel setFrame:titleLabelRect];
    }
    else
    {
        CGRect titleLabelRect = CGRectMake(0, (self.frame.size.height - height) / 2.0, self.frame.size.width, height);
        [_titleLabel setFrame:titleLabelRect];
    }
}

- (NSString *)titleWhenDraggingBeforeLoadingPreparedRange
{
    return _titleWhenDraggingBeforeLoadingPreparedRange;
}

- (void)setTitleWhenDraggingBeforeLoadingPreparedRange:(NSString *)title
{
    _titleWhenDraggingBeforeLoadingPreparedRange = [title copy];
    [self updateDisplayStatus:_displayStatus];
}

- (NSString *)titleWhenDraggingInLoadingRange
{
    return _titleWhenDraggingInLoadingRange;
}

- (void)setTitleWhenDraggingInLoadingRange:(NSString *)title
{
    _titleWhenDraggingInLoadingRange = [title copy];
    [self updateDisplayStatus:_displayStatus];
}

- (NSString *)titleWhenOnLoading
{
    return _titleWhenOnLoading;
}

- (void)setTitleWhenOnLoading:(NSString *)title
{
    _titleWhenOnLoading = [title copy];
    [self updateDisplayStatus:_displayStatus];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _contentVAlign = PageLoadingAnimationViewContentVAlignBottom;
        [self initSubViews:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame contentVAlign:(PageLoadingAnimationViewContentVAlign)contentVAlign
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _contentVAlign = contentVAlign;
        [self initSubViews:frame];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(PageLoadingAnimationViewDisplayStatus)displayStatus
{
    return _displayStatus;
}

-(void)initSubViews:(CGRect)frame
{
    //labelTitle
    _titleLabel = [[UILabel alloc] init];
    [self setTitleLabelHeight:TITLE_LABEL_DEFAULT_HEIGHT];
    
    _titleLabel.contentMode = UIViewContentModeCenter;
    _titleLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _spinner.hidesWhenStopped = YES;
    
    _spinnerRect = CGRectMake(_spinner.frame.size.width, _titleLabel.frame.origin.y + (_titleLabel.frame.size.height - _spinner.frame.size.height) / 2.0, _spinner.frame.size.width, _spinner.frame.size.height);
    _spinner.frame = _spinnerRect;
    [self addSubview:_spinner];
    //[self setOpaque:YES];
    
    self.titleWhenDraggingBeforeLoadingPreparedRange = DefaultTitleWhenDraggingBeforeLoadingPreparedRange;
    self.titleWhenDraggingInLoadingRange = DefaultTitleWhenDraggingInLoadingRange;
    self.titleWhenOnLoading = DefaultTitleWhenOnLoading;
    
    [_titleLabel setText:self.titleWhenDraggingBeforeLoadingPreparedRange];
}

-(void)updateDisplayStatus:(PageLoadingAnimationViewDisplayStatus)displayStatus
{
    _displayStatus = displayStatus;
    
    if(displayStatus == PageLoadingAnimationViewDisplayStatusWhenDraggingBeforeLoadingPreparedRange)
    {
        [_titleLabel setText:self.titleWhenDraggingBeforeLoadingPreparedRange];
        [_spinner stopAnimating];
    }
    else if (displayStatus == PageLoadingAnimationViewDisplayStatusWhenDraggingInLoadingRange)
    {
        [_titleLabel setText:self.titleWhenDraggingInLoadingRange];
        [_spinner stopAnimating];
    }
    else if (displayStatus == PageLoadingAnimationViewDisplayStatusWhenOnLoading)
    {
        [_titleLabel setText:self.titleWhenOnLoading];
        [_spinner startAnimating];
    }
}


@end
