![image](https://github.com/liuzechen/CCEaseRefresh/raw/master/CCEaseRefresh.gif)

#CCEaseRefresh :sparkles:

`CCEaseRefresh`是仿照网易新闻version5.3.4的下拉刷新。继承UIControl, 简单易用。
如您搜到`CCEaseRefresh`, 请star予以支持(*^__^*) ……

### 如何使用
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
#### 更新
`CCEaseRefresh`会不间断更新, 最后会走上Swift的不归路！
> 1.0 仿照网易新闻version5.3.4的下拉刷新


#### 作者 
刘泽琛, 1040981145@qq.com
