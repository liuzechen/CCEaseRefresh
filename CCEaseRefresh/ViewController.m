//
//  ViewController.m
//  NetEaseRefresh
//
//  Created by v－ling on 15/9/18.
//  Copyright (c) 2015年 LiuZeChen. All rights reserved.
//

#import "ViewController.h"
#import "CCEaseRefresh.h"

@interface ViewController ()

@property (weak, nonatomic)   IBOutlet UITableView *tableView;
@property (strong, nonatomic) CCEaseRefresh *refreshView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CCEaseRefresh";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.refreshView = [[CCEaseRefresh alloc] initInScrollView:self.tableView];
    [self.refreshView addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
    UIImage *dabai = [UIImage imageNamed:@"dabai.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, dabai.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = dabai;
    self.tableView.tableHeaderView = imageView;
}

- (void)dropViewDidBeginRefreshing:(CCEaseRefresh *)refreshControl {
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

@end
