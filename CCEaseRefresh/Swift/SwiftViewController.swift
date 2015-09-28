//
//  SwiftViewController.swift
//  CCEaseRefresh
//
//  Created by v－ling on 15/9/28.
//  Copyright © 2015年 LiuZechen qq:1040981145. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var refresh: CCEaseRefresh!

    deinit {
        print("SwiftViewController dealloc ...")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        refresh.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 配置 table
        self.configTableView()

        // 配置 refresh
        refresh = CCEaseRefresh(scrollView: self.tableView)
        refresh.addTarget(self, action: Selector("dropViewDidBeginRefreshing:"), forControlEvents: UIControlEvents.ValueChanged)

        // 自动刷新
        refresh.beginRefreshing()
    }

    func configTableView() {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "dabai.jpg")
        imageView.backgroundColor = UIColor.redColor()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, 211)
        self.tableView.tableHeaderView = imageView
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    }

    // 开始刷新
    func dropViewDidBeginRefreshing(refresh: CCEaseRefresh) {
        self.performSelector(Selector("stopRefresh"), withObject: nil, afterDelay: 3)
    }

    // 停止刷新
    func stopRefresh() {
        refresh.endRefreshing()
    }
}
