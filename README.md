![image](https://github.com/liuzechen/CCEaseRefresh/raw/master/CCEaseRefresh.gif)

#CCEaseRefresh :sparkles:

`CCEaseRefresh`是仿照网易新闻version5.3.4的下拉刷新。继承UIControl, 简单易用。
如您搜到`CCEaseRefresh`, 请star予以支持(*^__^*) ……

#### 如何使用

> #### OBJECTIVE-C
```
#import "CCEaseRefresh.h"
// 初始化
CCEaseRefresh *refreshControl = [[CCEaseRefresh alloc] initInScrollView:self.tableView];

// 添加相应事件
[refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

// 开始刷新
[refreshControl beginRefreshing];

// 停止刷新
[refreshControl endRefreshing];
```	

> #### SWIFT
```	
// 初始化
var refresh: CCEaseRefreshrefresh = CCEaseRefresh(scrollView: self.tableView)

// 添加相应事件
refresh.addTarget(self, action: Selector("dropViewDidBeginRefreshing:"), forControlEvents: UIControlEvents.ValueChanged)

// 开始刷新
refresh.beginRefreshing()

// 停止刷新
refresh.endRefreshing()
```	
#### 更新
`CCEaseRefresh`会不间断更新！
> 1.0 仿照网易新闻version5.3.4的下拉刷新

#### 作者 
刘泽琛, 1040981145@qq.com

#### 修复BUG
> 0.1 修复程序调用beginRefreshing后小球不显示的问题。

#### 链接
> 1.🌟星光闪烁特效: https://github.com/liuzechen/CC_Twinkle
