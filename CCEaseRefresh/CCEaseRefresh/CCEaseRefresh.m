//
//  CCEaseRefresh.m
//  CCEaseRefresh
//
//  Created by v－ling on 15/9/18.
//  Copyright (c) 2015年 LiuZeChen. All rights reserved.
//

#import "CCEaseRefresh.h"
#import <QuartzCore/QuartzCore.h>

#define kRefreshViewHeight 64
#define kTimeViewHeight    15
#define kTimeBottomEdage   8
#define kSubviewEdage      7
#define kBallImage         [UIImage imageNamed:@"refresh_sphere"]
#define kCircelImage       [UIImage imageNamed:@"refresh_circle"]
#define kContentOffset     @"contentOffset"
#define kAttributeDict     @{NSFontAttributeName: [UIFont systemFontOfSize:12.0]}

@interface CCEaseRefresh () {
    CGFloat _ballWidth;     ///< 球的宽
    CGFloat _ballHeight;    ///< 球的高
    CGFloat _circleWidth;   ///< 圆的宽
    CGFloat _circleHeight;  ///< 圆的高
    CGFloat _defaultBallY;  ///< 球的初始Y
    CGFloat _textX;         ///< 文本的X
    CGFloat _textY;         ///< 文本的Y
    CGFloat _currentOffsetY;///< scrollView的当前offset的Y
}

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) CALayer       *ballLayer;
@property (nonatomic, strong) CALayer       *circleLayer;
@property (nonatomic, copy)   NSString      *lastUpdateTimeString;
@property (nonatomic, assign) UIEdgeInsets  originalContentInset;

@end

@implementation CCEaseRefresh

#pragma mark - 初始、释放
- (instancetype)initInScrollView:(UIScrollView *)scrollView {
    self = [super initWithFrame:CGRectMake(0, scrollView.contentInset.top, scrollView.frame.size.width, kRefreshViewHeight)];
    if (self) {
        NSAssert(scrollView, @"CCEaseRefresh's scrollView can't is nil");

        self.scrollView = scrollView;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];

        [self.scrollView addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:nil];
        [self.scrollView.superview insertSubview:self belowSubview:scrollView];

        [self loadComponent];
    }
    return self;
}

- (void)dealloc {
    printf("CCEaseRefresh(OC) deinit...\n");
    [self.scrollView removeObserver:self forKeyPath:kContentOffset];
    self.scrollView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self.scrollView removeObserver:self forKeyPath:kContentOffset];
        self.scrollView = nil;
    }
}

- (void)drawRect:(CGRect)rect {
    [self calcTextXY];
    [_lastUpdateTimeString drawAtPoint:CGPointMake(_textX, _textY) withAttributes:kAttributeDict];
}

- (void)calcTextXY {
    if (_textY == 0 || _textX == 0) {
        CGSize textSize = [_lastUpdateTimeString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:kAttributeDict context:nil].size;
        _textY = self.frame.size.height - textSize.height - kSubviewEdage;
        _textX = (self.frame.size.width - textSize.width) / 2;
    }
}

#pragma mark - 加载零件
- (void)loadComponent {
    [self updateTime];
    [self calcTextXY];
    
    // 球和圆View
    _ballWidth = kBallImage.size.width   - kSubviewEdage / 2;
    _ballHeight = kBallImage.size.height - kSubviewEdage / 2;
    _ballLayer = [CALayer layer];
    _ballLayer.frame = CGRectMake((self.frame.size.width - _ballWidth) / 2, -_ballHeight, _ballWidth, _ballHeight);
    _ballLayer.position = CGPointMake(self.center.x, _ballLayer.position.y);
    _ballLayer.contents = (id)kBallImage.CGImage;
    _ballLayer.masksToBounds = YES;
    _circleWidth = kCircelImage.size.width;
    _circleHeight = kCircelImage.size.height;
    _circleLayer = [CALayer layer];
    _circleLayer.frame = CGRectMake((self.frame.size.width - _circleWidth) / 2, 0, _circleWidth, _circleHeight);
    _circleLayer.contents = (id)kCircelImage.CGImage;
    _circleLayer.hidden = YES;
    _defaultBallY = _ballLayer.frame.origin.y;

    // 添加到self、设置透明度
    [self setAlpha:0.f];
    [self.layer addSublayer:_ballLayer];
    [self.layer insertSublayer:_circleLayer below:_ballLayer];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kContentOffset]) {
        // offset
        _currentOffsetY = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue].y;
        // 判断是否可以进入刷新状态
        CGFloat newOffsetThreshold = -_originalContentInset.top;

        if (_refreshState == CCEaseRefreshStateLoading || _currentOffsetY > newOffsetThreshold) {return;}

        if (!self.scrollView.isDragging && _refreshState == CCEaseRefreshStateTrigger) {
            self.refreshState = CCEaseRefreshStateLoading;
        }else if (_currentOffsetY <= newOffsetThreshold * 2 && self.scrollView.isDragging) {
            self.refreshState = CCEaseRefreshStateTrigger;
        }else if (_currentOffsetY < newOffsetThreshold && _currentOffsetY > newOffsetThreshold * 2  && _refreshState != CCEaseRefreshStateLoading) {
            self.refreshState = CCEaseRefreshStateVisible;
        }else if (_currentOffsetY >= newOffsetThreshold && _refreshState != CCEaseRefreshStateDefault && _refreshState != CCEaseRefreshStateLoading) {
            // refreshState != CCRefreshDefault:进入默认状态后,在没有做上拉或下拉刷新时,不给refreshState的setter方法,从而启到优化程序的作用.想让谁少走几次owner != owner.
            self.refreshState = CCEaseRefreshStateDefault;
        }
        return;
    }
}

#pragma mark - set方法群
- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _originalContentInset = _scrollView.contentInset;
    _scrollView.backgroundColor = [UIColor clearColor];
}

- (void)setRefreshState:(CCEaseRefreshState)refreshState {
    _refreshState = refreshState;
    switch (_refreshState) {
        case CCEaseRefreshStateDefault:
        {
            [self updateTime];
            [self updateContentInset:_originalContentInset];
        }
            break;
        case CCEaseRefreshStateVisible:
        {
            [self updateTime];
            [self updateBallLayerPosition];
        }
            break;
        case CCEaseRefreshStateTrigger:
        {
            [self updateTime];
        }
            break;
        case CCEaseRefreshStateLoading:
        {
            UIEdgeInsets ei = _originalContentInset;
            ei.top = ei.top + kRefreshViewHeight;
            [self updateContentInset:ei];
            [self updateTime];
            [self updateBallLayerPosition];
            [self updatecircleLayerPosition];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 更新(Layer的Frame、刷新的时间)
- (void)updateBallLayerPosition {
    // fabs(_currentOffsetY) - _originalContentInset.top从0.f开始升序
    CGFloat ballLayerMinY = fabs(_currentOffsetY) - _originalContentInset.top + _defaultBallY;
    CGFloat ballLayerMaxY = _textY - kSubviewEdage - _ballHeight / 2;
    if (ballLayerMinY >= ballLayerMaxY) {
        ballLayerMinY  = ballLayerMaxY;
    }

    // 去掉隐式动画
    // 1.
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    _ballLayer.position = CGPointMake(_ballLayer.position.x, ballLayerMinY);
    [CATransaction commit];
    // 2.
    _ballLayer.actions = @{@"position":[NSNull null]};

    // 更新self的透明度
    self.alpha = (fabs(_currentOffsetY) - _originalContentInset.top) / kRefreshViewHeight;
    self.layer.hidden = NO;
}

- (void)updatecircleLayerPosition {
    _circleLayer.position = CGPointMake(_circleLayer.position.x, _ballLayer.position.y - kSubviewEdage);
    _circleLayer.hidden = NO;
    // 开始动画
    [self ballAnimation];
}

// 更新contentInset
- (void)updateContentInset:(UIEdgeInsets)ei {
    [UIView animateWithDuration:.25 animations:^{
        _scrollView.contentInset = ei;
    }];
}

- (void)updateTime {
    switch (_refreshState) {
        case CCEaseRefreshStateDefault:
        case CCEaseRefreshStateVisible:
            _lastUpdateTimeString = CCEaseDefaultTitle;
            break;
        case CCEaseRefreshStateTrigger:
            _lastUpdateTimeString = CCEaseTriggertTitle;
            break;
        case CCEaseRefreshStateLoading:
            _lastUpdateTimeString = CCEaseLoadingTitle;
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

#pragma mark - 动画(CoreAnimation)
- (void)ballAnimation {
    CABasicAnimation *enlarge = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    enlarge.duration = .5;
    enlarge.repeatCount = 1;
    enlarge.removedOnCompletion = NO;
    enlarge.fromValue = [NSNumber numberWithFloat:.5];
    enlarge.toValue = [NSNumber numberWithFloat:1];
    CABasicAnimation *decrease = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    decrease.duration = .5;
    decrease.repeatCount = 1;
    decrease.removedOnCompletion = NO;
    decrease.beginTime = .5;
    decrease.fromValue = [NSNumber numberWithFloat:1];
    decrease.toValue = [NSNumber numberWithFloat:.5];
    CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
    position.duration = 1;
    position.repeatCount = MAXFLOAT;
    position.fromValue = [NSValue valueWithCGPoint:_circleLayer.position];
    position.toValue = [NSValue valueWithCGPoint:CGPointMake(_circleLayer.position.x, _circleLayer.position.y + kTimeViewHeight)];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1;
    group.repeatCount = MAXFLOAT;
    group.removedOnCompletion = NO;
    group.autoreverses = YES;
    group.animations = [NSArray arrayWithObjects:enlarge, decrease, position, nil];
    [_circleLayer addAnimation:group forKey:@"CCEaseRefresh"];
}

#pragma mark - 开始刷新、结束刷新
- (void)beginRefreshing {
    if (_refreshState != CCEaseRefreshStateLoading) {
        self.refreshState = CCEaseRefreshStateLoading;
    }
}

- (void)endRefreshing {
    if (_refreshState != CCEaseRefreshStateDefault) {
        self.refreshState = CCEaseRefreshStateDefault;
        self.alpha = 0.f;
        self.layer.hidden = YES;

        [_circleLayer removeAnimationForKey:@"CCEaseRefresh"];
        [_circleLayer setHidden:YES];
        _ballLayer.position = CGPointMake(_ballLayer.position.x, _defaultBallY);
    }
}

@end
