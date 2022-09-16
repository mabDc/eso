### 2022.09.15
- 历史记录性能大优化
- 主题完善，模式和调色板整合
- add 增加白天主题和黑夜主题分离两套设置
- 初始效果优化
- 幺蛾子（bugs）
   - 搜索历史聚焦

### 2022.09.15
- 文字阅读 优化
- 所有配置都替换hive保存，sp清空
- 搜索历史换用标签
- 主题设置底部增加很多颜色可以参考和复制
- 还有很多幺蛾子(bugs)
   - 搜索聚焦bug
   - 历史记录有性能问题
   - 主题内置

### 2022.09.13
- fix 修复 双栏 中间阴影
- add 增加 文字动效
   - 四向覆盖
   - 水平覆盖
   - 垂直覆盖
   - 滑动
   - 水平滑动
   - 垂直滑动
   - 模拟滚动
- fix 修复 xpath only替换br为换行
- add 增加 规则多选导出，分享结果编辑
   - 上传netcut.cn
   - 复制到剪贴板
   - 分享结果
   - 分享地址
- 更新版本号16，今年第16个版本

### 2022.09.12
- fix 目录为空
- 书架使用hive保存
- 主题使用hive保存
   - 生效夜间模式
   - 背景图
   - 主题色
   - 背景色
- 加入新bug，删掉了一些存储，重启APP可能丢失部分信息

### 2022.09
- xpath增加`/only()`以区别`/text()`,不取下级标签
- 输入框支持历史、撤销、重做
- 更新编译插件，桌面版输入框支持`ctrl+z`撤销和`ctrl+shif+z`重做。
- 增加跳目录规则，目录不展示直接进正文
   - 目录地址填正文直接使用搜索、发现结果进入正文解析
   - 目录章节名填正文直接使用章节结果进入正文解析
- 增加图文，在规则类型中选择。使用旧代码，排版没问题。排版自定义未开放。
- 版本号同步大炮，更新至15。

### 2022.3.23
- fix 优化一些问题
### 2022.3.22
- 新版本 1.22.4+12204
- 本地读取txt完成
- 本地读取epub完成
- 规则搜索现在是搜索名称、分组、作者和地址

### 2022.3.21
- add tts 朗读语速调节
- add 文字 亮度调节和常量
- update 更新插件库
- update 章节线路换用wrap显示 直接显示全部线路
- add 增加更新至按钮和阅读至按钮
- fix 线路自动切换至当前进度了
- 支持本地txt和epub 章节解析未完成

### 2022.3.13
- fix 文字自动缓存 缓存章节显示错误
- add 允许修改文字缓存导出目录

### 编译ipa包 需要自签名或者越狱安装

### 2022.3.4
- 桌面端音频播放器暂时使用视频播放器
- 导入导出全部用编码
- xpath支持/html()来获取html文本
- 修复window对象
- 修复某些开关不刷新问题

### 2022.2.24
- add xpath 结尾用node()时返回html字符串
- fix 安装包解析失败 适配安卓12

### 2022.2.24
- window端播放并入统一的缓存器
- fix 图片正文加载
- fix windows端播放切换地址

### 2022.2.23
- 多项更新
- add 图片类型也使用统一的缓存器
- add 图片`@headers`统一解析和管理
- add @webview: js部分将会重复执行 当返回`null`或者`空字符串`时将重复执行
- fix @webview: 实装baseUrl@@和result@@
- fix `searchItem`中`id`重复问题 使用新的生成方法 解决cache重复问题
- fix 等待图默认宽高改到400
- fix 保存图片
- fix 调试时可以使用print(...args)打印结果，如`print("test js result")` `print("/1.html", true)`
- remove 图片类正文中去掉position列表
- 版本号修改至`1.22.3+12203`
 
### 2022.2.19
- 额外编译关闭avx2的版本 尝试兼容老旧cpu （文件名带noavx2）

### 2022.2.19
- 增加webview规则
- `@web:[(baseUrl|result)@@]script0[\n\s*@@\s*\nscript1]`
- `@webview:[(baseUrl|result)@@]script0[\n\s*@@\s*\nscript1]`
- 示例：
   ``` 
      @web:
      var x = document.querySelectorAll(".mh_comicpic img");
      var y = x[0].src.split("0001");
      var a = [];
      for(var i = 1; i <= x.length; i++)
         a.push(y[0] + ("0000" + i).slice(-4) + y[1])
   
      a[0] += "@headers" + JSON.stringify({"referrer": "https://www.cocomanga.com/"})
      a
   ```
 - 版本号修改至`1.22.2+12202`
 - 增加桌面版按住滑动，类似移动版的操作逻辑

### 2022.2.17
- fix 主题`appbar`前景色
- pc播放器改进
   - https链接（可以不解析，直接网页）调用在线解析器 播放器更好用
   - 解决视频全屏问题
   - pc播放器剧集列表 在右下角和左上角
- 修复书架某些bug
- 更详细的解析日志
- 版本号修改至`1.22.1+12201` （对应2022年）
- 修复地址编码

### 2022.2.16
- PC端视频播放器
- 如果没反应请尝试滑动到页面底部下载微软的运行时
   - 用于嗅探和视频播放(任意安装一个都可以，win11已经内置不需要安装)
   - edge https://www.microsoftedgeinsider.com/zh-cn/
   - webview2 https://developer.microsoft.com/zh-cn/microsoft-edge/webview2/
- 下版本增加剧集 预解析 缓存
- fix bug 中文路径
- 优化视频按钮

### 2022.2.14

- 质量更新
- 更新多个插件库
- 增加请求测试与解析辅助工具
- `xpath`支持更复杂的规则 如 `//*[@class="r"][2]` `//*[@class="playlist"]/parent::*`

### 2022.1.25

- 尝试修复权限问题 还需要修改
- 增加视频支持headers，和图片写法一致: `url@headersjson`
- 更新部分插件版本
- js支持`css`方法：`var r = await css(html, selector)`

### 1.21.15

- 图片背景和字体选择
- fix 进度计算

### 1.21.14

- 安卓仿真重写
- 安卓仿真现在是翻整页了
- 修复数据库版本（7 到 8）问题
- 增加双面翻页
- 双面翻页增加到左右两种
- 仿真可以选择使用高清截图
- 规则兼容`ZY-Player`视频源，支持文件导入，文本导入，网址导入等等

### 1.21.13

- flutter 换用 2.x
- 升级 plugins（非常多，jsonpath 可以写表达式）
- 文件管理器换内置

### 1.21.12

- fix 新版本信息首次打开才会显示
- fix 文字阅读弹出
- add 单源的发现和搜索增加跳页
- add JS 代码高亮和运行测试
- add 增加可选文字底部横线

### 1.21.11

- 移除新春快乐
- 缩短开屏等待时间
- 文字正文进度保存
- 修复宽屏搜索结果点击
- 恢复文字正文目录跳转和分享菜单
- 自定义文字和背景颜色
- tts 朗读
- 缓存
- 本地缓存和内存缓存对文字和视频生效
- 视频预解析
- 嗅探超时从 8s 改成 10s

### 1.21.10-fix

- 增加翻转翻页 为双栏使用
- 更改 picture 保存和使用 动画更流畅
- 使用限制长度的 memerycache 节约资源
- 翻转动画现在很流畅

### 1.21.10

- 重写文字正文
- 多种仿真效果
  - [x] 仿真翻页（苹果样式）
  - [x] 仿真翻页（安卓样式）
  - [x] 覆盖翻页
  - [x] 多栏排版
- 尝试修复配置文件读取错误
- 文字增加配色选择 示例效果 更多选项

### 1.21.09

- 优化横屏 桌面 TV 平板 （自动旋转后自动判断宽度）
- 更换正文排版
- 宽屏 文字正文双栏布局

### 1.21.08

- JS 引擎更换为 flutter_qjs 0.3.5
- 全局内置 cryptoJS
- 增加 (其中网络请求是异步)
  - xpath(html, xpath)
  - http(url)
  - http.get(url)
  - http.post(url, body, \[headers\])
  - http.put(url, body, \[headers\])

### 1.21.07

- 增加更多的查看原网页
- 增加继续阅读按钮
- 增加简易换源
- 修复一些可能的问题

### 1.21.06

- 重写 windows 视频播放
- 如果出现 ceatecorewebview2enviroment 错误需要安装嗅探工具（二选一）
  edge 内测版 https://www.microsoftedgeinsider.com/zh-cn/
  或者
  webview2 运行时 https://developer.microsoft.com/zh-cn/microsoft-edge/webview2/

### 1.21.05

- 粗糙版 tts
- 增加无障碍标签
- windows tts 感谢 [ekibun](https://github.com/ekibun)
- 正文页增加当前项目缓存清理按钮
- 更新 flutter 至最新 master 分支
- 增加倍速播放

### 1.21.04 fix

- 修复正文状态栏自动隐藏
- 修复自动上传
- 修复发现

### 1.21.04

- webdav 规则分享与获取
- 历史浏览可删除
- 允许仅恢复规则

### 1.21.03

- webdav 与备份文件，桌面版移动版使用不同文件名
- 文字、图片正文状态栏信息栏设置
- 界面按钮允许自定义 多种布局

### 1.21.01 1.21.02

- fix 文字正文有时候灰屏
- 备份恢复重写
- 2021 新春快乐
- 自动备份
- webdav

### 1.20.18 1.20.19

- menu 重写
- 详情页增加规则编辑入口
- 导入重写
- 规则管理重绘
- 文本输入框代码清理
- 完成规则管理批量操作
- 增加发现页规则编辑入口
- 支持 base64 图片地址 `data:image/xx;base64,xx`
- 监听图片页数 记录和恢复页数进度
- 更新安卓 sdk 修复安卓 11 闪退

### 10.24

- fix 历史记录天数计算
- 修改数据库
- 改用下一页
- fix 恢复时修改 version 信息
- 地址为`'null'`跳过请求
- 调试时显示封面
- fix 历史进度保存

### 10.17

- 目录可选显示更新时间和封面
- 修复目录多线路 index bug

### 10.16

- 支持两级目录
- 更改历史日期计算（0 点分界）

### 10.13

- 浏览历史

### 10.9

- 视频缩放
- ios 卡界面已确认修复

### 9.29

- 桌面三端适配键盘操作
  - 上一页：方向键左、上、上一页`pageup`
  - 下一页：方向键右、下、下一页`pagedown`
  - 上一章：方括号左`[`、减号`-`、插入键`insert`或`ins`
  - 上一章：方括号右`]`、小键盘加号`+`、删除键`delete`或`del`
  - 菜单：回车`enter`
- 歌词改进（感谢大白）
- 图片背景
- fix 目录布局问题

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
- 修改 windows 部分，打包并上传 windows 端

计划：

- 章节线路和分卷
- 排版自定义颜色、背景、图片背景
- 启动检查（每天/每次）（收藏更新、日志更新、app 更新等）

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
- 字体文件放于 eso/font 文件夹下
- 修复 js、http 规则 bug
- 漫画增加全屏开关（挖孔屏和刘海屏关闭后去掉黑条）
- 修复正文自定义字体对齐和分页排版问题

### 9.18

- 更新插件 windows 支持
- 修复章节检查错误

下版本计划：

- 章节自动检查(每天/每次)
- 歌词
- 自定义背景
- 自定义文字
- 支持 base64 图片地址

### 9.17

- 安卓 js 报错信息
- 修复文字正文图片吃内容 bug
- 修复章节倒序显示问题
- 收藏增加章节检查。实装下拉刷新

下版本计划：

- 歌词
- 自定义背景
- 自定义文字
- 支持 base64 图片地址

### 9.14

- 增加嗅探
- 改用 dev 分支编译

### 9.12

- 增加字体选择

### 9.4

- 增加搜索历史记录

- 更新 jsonpath 版本，修复元素\[position\]选取 bug

- 增加首次进入显示版本信息

- 更新版本号

  以上来自 [mabDc](https://github.com/mabDc)

### 9.2

- 规则排序

- 更新版本号

  以上来自 [mabDc](https://github.com/mabDc)

### 8.31

- 增加 linux 版本

- 增加`@http:`规则

- 修复文件分享权限

  以上来自 [mabDc](https://github.com/mabDc)

### 8.11

- gbk 编码范围生效到非 ascii 编码段

- 增加快速滚动条

- 发现 js 支持 List

- 修复重新加载

- 缓存导出功能

- 自动缓存功能

- 允许视频后台播放音频开关

- 替换 jsonpath 实现库

- 增加 ios 保存图片到相册权限

- 缓存分享功能

  以上来自 [mabDc](https://github.com/mabDc)

### 7.25

- 去掉并发

- 章节多页时增加并发

- js 中增加 page

- http client post 301 和 302 自动跳转

- windows 使用网页播放视频

- 正文支持正则

- page 匹配正则

- 更改请求模版

- fix baseUrl 多页

- 修改 js 在 windows 上实现，换用 cpp plugin 方式

- 尝试搜索失败时释放 js 引擎

### 7.18

- 修复 js 多次初始化

- 修复发现列表布局问题

- 修复音量键翻页功能

- 修改规则编辑输入提示

- 修改搜索 id 和 content type 初始化

- 增加 win 平台音乐支持（还未完成）

- 修改输入模版

- 修复发现格子布局问题

- 测试页可以调试 js

- 测试 ijk

### 7.14

- 调整视频播放器

- audio 增加 tooltip 标题修改

- 优化视频播放页

- 加入一个测试页，方便测试功能

- 调整规则

- 调整视频播放 UI

- 使用 wke.dll 替换 QuickJs.dll，完美解决 win 平台 js 引擎问题

- windows 几乎完全支持 js 规则

- ios 亮度调节 视频亮度调节最小值改为 1（安卓设置为 0 或者更小会变为系统亮度）

- iosApp 设置名称

- 可以单次运行 js

- 增加 win 平台 js 实现。需要将 qjs.dll, QuickJS64.dll 放到 exe 目录

- macos 端小说阅读快捷键 -+换章节 <- ->换页 enter 显示 menu

- 修改 html 自动处理

### 7.12

- http 去掉 ssl 验证 可配置代理

- 视频播放手势

- 视频播放器重写

- 修改视频控制器

- 音频拖动条

- fix 发现分组某些问题

- 换回视频控制器

- 删除 oldapi, 优化功能

- 更换 videoplayer 测试

- join qq group

- 修改 sql 在 win 上的初始化

- windows (修复 sqlite.dll 路径问题，字体处理）

- 修复 win 平台 bug

- 更换 toast 为 oktoast

- 支持 windows （已完成 sqlite 兼容，还差 js)

- 修改 cookie

- 恢复数据时先请求权限

- 还原大番茄对 novel_page_provider.dart 的修改

### 7.8

- 增加 win 平台（未完）

- 去掉 url 抛出错误 阅读正文自动处理标签 支持图文

- 音乐播放页面增加收藏按钮

- 音频显示更多信息

- 规则管理页增加排序功能

- 修复 bug，增加备份和恢复功能

- 优化详情页和滚动条

- 详情页增加滚动拖动块，优化滚动拖动条

- fix 响应判断

- 增加 url 请求抛出错误

- 优化小说缓存功能（增加本地文件缓存），设置页面增加清理缓存功能

- 增加调试页销毁处理 地址规则增加 cookie 去掉分页重复判断

- profile 增加 novelTitlePadding

### 7.6 1.13.10+9912

1. 增加调试页销毁处理

2. 地址规则增加 cookie

3. 去掉分页重复判断，增加响应错误状态码抛出和空白响应终止解析

4. 安卓增加音量翻页

5. 优化小说缓存功能（增加本地文件缓存），设置页面增加清理缓存功能

### 7.4 1.13.8+6010

1. 图片详细页去掉单击返回（flutter 双击手势可能有问题

2. 规则登录的内置 webview 增加前进后退按钮

3. 修复&&规则部分问题

4. 发现规则支持 js

   以上来自 [mabDc](https://github.com/mabDc)

### 7.4 1.13.7+6009

1. 搜索页：普通和精确结果检查作者

2. 优化搜索处理（解决进度超过 100%问题）

3. 优化文字阅读菜单 UI

4. 修复视频播放时不能常亮屏幕问题

   以上来自 [yangyxd](https://github.com/yangyxd)

5. 修复复制模式字体颜色问题

6. 修复滑动模式切换章节 pullToRefresh 失效问题

7. 修改文字阅读模式不支持提示文本

8. 规则调试网址增加长按复制

9. 图文阅读增加图片长按效果

   以上来自 [mabDc](https://github.com/mabDc)

### 7.4 1.13.6+6008

1. 修复增加 page 规则后解析流程 bug by [mabDc](https://github.com/mabDc)

### 7.3 1.13.5+6007

1. 修复发现重复

2. 目录地址和正文地址可用 page

3. 修改 appbar title 留白大小

4. 聚合搜索计数修改

   以上来自 [mabDc](https://github.com/mabDc)

5. 阅读正文重写

6. 增加提示和操作引导

7. 修复文本输入框 bug

8. 增加发现请求错误处理

9. 章节详情页图片长按效果

   以上来自 [yangyxd](https://github.com/yangyxd)

10. ios 视频退出播放手动设置竖屏

    以上来自 [DaguDuiyuan](https://github.com/DaguDuiyuan)

### 7.2

1. 阅读正文重写（未完成） by [yangyxd](https://github.com/yangyxd)

2. xpath 解析属性可用双引号 by [mabDc](https://github.com/mabDc)

3. 修改规则链式解析 by [mabDc](https://github.com/mabDc)

4. 音频增加跨源循环模式 by [yangyxd](https://github.com/yangyxd)

### 6.29

1. 发现列表页小分类增加展开收起功能（超过 8 个在右边显示侧边栏）

2. 音频增加跨源循环模式

   by [yangyxd](https://github.com/yangyxd)

### 6.28

1. 修复 DLNA 投屏 by [mabDc](https://github.com/mabDc)

2. 发现增加类型过滤 by [yangyxd](https://github.com/yangyxd)

3. 修复发现关键字刷新后失效 by [yangyxd](https://github.com/yangyxd)

4. 更新版本至 `1.13.1+2003`

5. 增加 dlna 30s 自动停止搜索

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

1. 发现增加 2 级分类

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
