//
//  OCViewController.m
//  CCEaseRefresh
//
//  Created by v－ling on 15/9/28.
//  Copyright © 2015年 LiuZechen qq:1040981145. All rights reserved.
//

#import "OCViewController.h"
#import "CCEaseRefresh.h"

@interface OCViewController ()

@property (strong, nonatomic) CCEaseRefresh *refreshView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OCViewController

- (void)dealloc
{
    printf("OCViewController dealloc ...\n");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.refreshView endRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // config table
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIImage *dabai = [UIImage imageNamed:@"dabai.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, dabai.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = dabai;
    self.tableView.tableHeaderView = imageView;

    // config refresh
    self.refreshView = [[CCEaseRefresh alloc] initInScrollView:self.tableView];
    [self.refreshView addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

    // auto refresh
    [self.refreshView beginRefreshing];
}

- (void)dropViewDidBeginRefreshing:(CCEaseRefresh *)refreshControl {
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

@end
