//
//  CCEaseRefresh.h
//  CCEaseRefresh
//
//  Created by v－ling on 15/9/18.
//  Copyright (c) 2015年 LiuZeChen. All rights reserved.
//

#import <UIKit/UIKit.h>

// 刷新状态枚举
typedef NS_ENUM(NSInteger, CCEaseRefreshState) {
    CCEaseRefreshStateDefault = 0,
    CCEaseRefreshStateVisible = 1,
    CCEaseRefreshStateTrigger = 2,
    CCEaseRefreshStateLoading = 3
};

#define CCEaseDefaultTitle  @"下拉刷新"
#define CCEaseTriggertTitle @"松开刷新"
#define CCEaseLoadingTitle  @"正在刷新"
#define CCUpdateTimeKey     @"CCUpdateTimeKey"

@interface CCEaseRefresh : UIControl

// 刷新状态
@property (nonatomic, assign) CCEaseRefreshState refreshState;

// 初始化
- (instancetype)initInScrollView:(UIScrollView *)scrollView;

// 刷新方法
- (void)beginRefreshing;
- (void)endRefreshing;

@end
