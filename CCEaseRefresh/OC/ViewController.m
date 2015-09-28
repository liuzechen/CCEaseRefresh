//
//  ViewController.m
//  NetEaseRefresh
//
//  Created by v－ling on 15/9/18.
//  Copyright (c) 2015年 LiuZeChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic)   IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CCEaseRefresh";

}

#pragma mark - 

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSInteger row = indexPath.row;
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = row == 0? @"OC": @"Swift";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row == 0) {
        [self performSegueWithIdentifier:@"CEOC" sender:nil];
    } else if (row == 1) {
        [self performSegueWithIdentifier:@"CESwift" sender:nil];
    }
}

@end
