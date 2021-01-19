### 1.21.03
- webdav与备份文件，桌面版移动版使用不同文件名
- 文字、图片正文状态栏信息栏设置
- 界面按钮允许自定义 多种布局

### 1.21.01 1.21.02
- fix 文字正文有时候灰屏
- 备份恢复重写
- 2021 新春快乐
- 自动备份
- webdav

### 1.20.18 1.20.19

- menu重写
- 详情页增加规则编辑入口
- 导入重写
- 规则管理重绘
- 文本输入框代码清理
- 完成规则管理批量操作
- 增加发现页规则编辑入口
- 支持base64图片地址 `data:image/xx;base64,xx`
- 监听图片页数 记录和恢复页数进度
- 更新安卓sdk 修复安卓11闪退

 ### 10.24

- fix 历史记录天数计算
- 修改数据库
- 改用下一页
- fix 恢复时修改version信息
- 地址为`'null'`跳过请求
- 调试时显示封面
- fix 历史进度保存

### 10.17

- 目录可选显示更新时间和封面
- 修复目录多线路index bug

### 10.16

- 支持两级目录
- 更改历史日期计算（0点分界）

### 10.13

- 浏览历史

### 10.9

- 视频缩放
- ios卡界面已确认修复

### 9.29

- 桌面三端适配键盘操作
  - 上一页：方向键左、上、上一页`pageup`
  - 下一页：方向键右、下、下一页`pagedown`
  - 上一章：方括号左`[`、减号`-`、插入键`insert`或`ins`
  - 上一章：方括号右`]`、小键盘加号`+`、删除键`delete`或`del`
  - 菜单：回车`enter`
- 歌词改进（感谢大白）
- 图片背景
- fix目录布局问题

### 9.28

- 图片背景
- 修复未备份先恢复报错
- 增加键盘响应

### 9.27

- 规则剪贴板导入可以是网址
- 文字正文字色和背景自定义
- 支持多线路

### 9.24

- 恢复数据增加文件选择或使用默认文件
- 修改windows部分，打包并上传windows端

计划：
- 章节线路和分卷
- 排版自定义颜色、背景、图片背景
- 启动检查（每天/每次）（收藏更新、日志更新、app更新等）

### 9.23

- 修复播放歌单时章节点击无效
- 歌词（高亮、滚动、拖拽、播放）
- 更新版本
- 备份和恢复增加搜索关键词历史
- 文字正文设置增加字体和调色板入口
- 文字正文可以自定义字体颜色、背景颜色和背景图片
- 更新版本

### 9.21

- 正文、界面独立字体设置
- 字体文件放于eso/font文件夹下
- 修复js、http规则bug
- 漫画增加全屏开关（挖孔屏和刘海屏关闭后去掉黑条）
- 修复正文自定义字体对齐和分页排版问题

### 9.18

- 更新插件windows支持
- 修复章节检查错误

下版本计划：
- 章节自动检查(每天/每次)
- 歌词
- 自定义背景
- 自定义文字
- 支持base64图片地址

### 9.17

- 安卓js报错信息
- 修复文字正文图片吃内容bug
- 修复章节倒序显示问题
- 收藏增加章节检查。实装下拉刷新

下版本计划：
- 歌词
- 自定义背景
- 自定义文字
- 支持base64图片地址

### 9.14

- 增加嗅探
- 改用dev分支编译

### 9.12

- 增加字体选择

### 9.4

- 增加搜索历史记录

- 更新jsonpath版本，修复元素\[position\]选取bug

- 增加首次进入显示版本信息

- 更新版本号

    以上来自 [mabDc](https://github.com/mabDc)

### 9.2

- 规则排序

- 更新版本号

    以上来自 [mabDc](https://github.com/mabDc)

### 8.31

- 增加linux版本

- 增加`@http:`规则

- 修复文件分享权限

    以上来自 [mabDc](https://github.com/mabDc)

### 8.11

- gbk编码范围生效到非ascii编码段

- 增加快速滚动条

- 发现js支持List

- 修复重新加载

- 缓存导出功能

- 自动缓存功能

- 允许视频后台播放音频开关

- 替换jsonpath实现库

- 增加ios保存图片到相册权限

- 缓存分享功能

    以上来自 [mabDc](https://github.com/mabDc)

### 7.25

- 去掉并发

- 章节多页时增加并发

- js中增加page

- http client post 301和302自动跳转

- windows使用网页播放视频

- 正文支持正则

- page匹配正则

- 更改请求模版

- fix baseUrl多页

- 修改js在windows上实现，换用cpp plugin方式

- 尝试搜索失败时释放js引擎

### 7.18

- 修复js多次初始化

- 修复发现列表布局问题

- 修复音量键翻页功能

- 修改规则编辑输入提示

- 修改搜索id和content type初始化

- 增加win平台音乐支持（还未完成）

- 修改输入模版

- 修复发现格子布局问题

- 测试页可以调试js

- 测试ijk

### 7.14

- 调整视频播放器

- audio增加tooltip 标题修改

- 优化视频播放页

- 加入一个测试页，方便测试功能

- 调整规则

- 调整视频播放UI

- 使用wke.dll替换QuickJs.dll，完美解决win平台js引擎问题

- windows几乎完全支持js规则

- ios亮度调节 视频亮度调节最小值改为1（安卓设置为0或者更小会变为系统亮度）	

- iosApp设置名称

- 可以单次运行js

- 增加 win 平台 js 实现。需要将 qjs.dll, QuickJS64.dll 放到 exe 目录

- macos端小说阅读快捷键 -+换章节 <- ->换页 enter显示menu

- 修改html自动处理


### 7.12

- http去掉ssl验证 可配置代理

- 视频播放手势

- 视频播放器重写

- 修改视频控制器

- 音频拖动条

- fix 发现分组某些问题

- 换回视频控制器

- 删除 oldapi, 优化功能

- 更换videoplayer 测试

- join qq group

- 修改sql在win上的初始化

- windows (修复sqlite.dll路径问题，字体处理）

- 修复win平台bug

- 更换toast为oktoast

- 支持 windows （已完成sqlite兼容，还差js)

- 修改cookie

- 恢复数据时先请求权限

- 还原大番茄对 novel_page_provider.dart 的修改


### 7.8

- 增加 win 平台（未完）

- 去掉url抛出错误 阅读正文自动处理标签 支持图文

- 音乐播放页面增加收藏按钮

- 音频显示更多信息

- 规则管理页增加排序功能

- 修复bug，增加备份和恢复功能

- 优化详情页和滚动条

- 详情页增加滚动拖动块，优化滚动拖动条

- fix 响应判断

- 增加url请求抛出错误

- 优化小说缓存功能（增加本地文件缓存），设置页面增加清理缓存功能	

- 增加调试页销毁处理 地址规则增加cookie 去掉分页重复判断

- profile 增加 novelTitlePadding

### 7.6  1.13.10+9912

1. 增加调试页销毁处理

2. 地址规则增加cookie

3. 去掉分页重复判断，增加响应错误状态码抛出和空白响应终止解析

4. 安卓增加音量翻页

5. 优化小说缓存功能（增加本地文件缓存），设置页面增加清理缓存功能

### 7.4  1.13.8+6010

1. 图片详细页去掉单击返回（flutter双击手势可能有问题

2. 规则登录的内置webview增加前进后退按钮

3. 修复&&规则部分问题

4. 发现规则支持js

    以上来自 [mabDc](https://github.com/mabDc)

### 7.4  1.13.7+6009

1. 搜索页：普通和精确结果检查作者

2. 优化搜索处理（解决进度超过100%问题）

3. 优化文字阅读菜单UI

4. 修复视频播放时不能常亮屏幕问题

    以上来自 [yangyxd](https://github.com/yangyxd)

5. 修复复制模式字体颜色问题

6. 修复滑动模式切换章节pullToRefresh失效问题

7. 修改文字阅读模式不支持提示文本

8. 规则调试网址增加长按复制

9. 图文阅读增加图片长按效果

    以上来自 [mabDc](https://github.com/mabDc)

### 7.4  1.13.6+6008

1. 修复增加page规则后解析流程bug by [mabDc](https://github.com/mabDc)

### 7.3  1.13.5+6007

1. 修复发现重复

2. 目录地址和正文地址可用page

3. 修改appbar title留白大小

4. 聚合搜索计数修改
    
    以上来自 [mabDc](https://github.com/mabDc)

5. 阅读正文重写 

6. 增加提示和操作引导 

7. 修复文本输入框bug 

8. 增加发现请求错误处理

9. 章节详情页图片长按效果

    以上来自 [yangyxd](https://github.com/yangyxd)

10. ios 视频退出播放手动设置竖屏 

    以上来自 [DaguDuiyuan](https://github.com/DaguDuiyuan)

### 7.2

1. 阅读正文重写（未完成） by [yangyxd](https://github.com/yangyxd)

2. xpath解析属性可用双引号 by [mabDc](https://github.com/mabDc)

3. 修改规则链式解析 by [mabDc](https://github.com/mabDc)

4. 音频增加跨源循环模式 by [yangyxd](https://github.com/yangyxd)

### 6.29

1. 发现列表页小分类增加展开收起功能（超过8个在右边显示侧边栏）  

2. 音频增加跨源循环模式

    by [yangyxd](https://github.com/yangyxd)

### 6.28

1. 修复DLNA投屏  by [mabDc](https://github.com/mabDc)

2. 发现增加类型过滤 by [yangyxd](https://github.com/yangyxd)

3. 修复发现关键字刷新后失效 by [yangyxd](https://github.com/yangyxd)

4. 更新版本至 `1.13.1+2003`

5. 增加 dlna 30s自动停止搜索

### 6.27 

1. 增加图源登录

2. 增加更新日志

    by [mabDc](https://github.com/mabDc)


### 6.26 

1. 文字阅读支持图文

2. 增加规则压缩分享 

3. 更新版本至`1.13.0+2002`

    by [mabDc](https://github.com/mabDc)


### 6.25

1. 发现增加2级分类

2. 修复响应自动解码 

    by [mabDc](https://github.com/mabDc)

### 6.23 

1. 更新图标 by [yangyxd](https://github.com/yangyxd)

### 6.22 

1. 重写文字正文 by [yangyxd](https://github.com/yangyxd)

### 6.20 

1. 修改发现界面 by [DaguDuiyuan](https://github.com/DaguDuiyuan)

### 6.16 

1. 修改详情页 by [yangyxd](https://github.com/yangyxd)

2. 增加图片正文查看和保存 by [yangyxd](https://github.com/yangyxd)

3. 增加正文下一章预加载 by [mabDc](https://github.com/mabDc)
