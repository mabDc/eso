# 特点

这是一个全平台支持的自定义客户端。

## 亦搜，亦看，亦闻

开源的多站点跨平台阅读器来啦！

支持多来源的自定义阅读器与播放器。

全平台支持，支持windows，安卓，ios，macos，linux，tv，6个平台。

ps: 所有内容来自互联网，app本身只是工具，不提供内容。

欢迎意见或建议，喜欢不妨点个star。

## 亦搜

多种来源，有发现，可搜索

## 亦看

看文字，看小说，看图片，看壁纸，看漫画，看视频

## 亦闻

听故事，听有声，听音乐，听英语

## 亦你所想，亦你所能

更多功能由君发挥，待君开发。

# 功能列表

- 平台
  - [x] 安卓
  - [x] tv
  - [x] ios（需要自签）
  - [x] windows
  - [x] Linux
  - [x] Macos
- 搜索
  - [x] 可选搜索类型
  - [x] 可调并发数
  - [x] 过滤搜索结果，可精确搜索
- 视频
  - [x] 音量手势
  - [x] 亮度手势
  - [x] 左右滑动调整进度
  - [x] 进度条拖拽
  - [x] 友好的提示
  - [x] 投屏：DLNA
  - [ ] 直播优化
- 其他
  - [ ] 启动时检查章节更新
  - [ ] 换源  

# 更新日志

见文件 [CHANGELOG](CHANGELOG.md)

# 一些图片

首先是视频，支持DLNA投屏，有音量、亮度、进度调节的手势控制，。

![视频](img/shipin1.jpg)

![视频](img/shipin3.jpg)

![视频](img/shipin2.jpg)

![视频](img/shipin4.jpg)

还有图片、壁纸、阅读等功能：

![新漫画](img/xinmanhua1.jpg)

![新漫画](img/xinmanhua3.jpg)

![新漫画](img/xinmanhua2.jpg)

![壁纸](img/bizhi1.jpg)

![北邮](img/beiyou1.jpg)

![知乎日报](img/zhihuribao1.jpg)

![知乎日报](img/zhihuribao2.jpg)

# 编译指南

不同平台有些插件不兼容，准备了多个依赖文件列表，必要时可替换yaml。

linux运行需要额外安装libsqlite3-dev。

macos和linux编译需要dev分支，windows需要master分支。

源码去除了规则解析部分，不影响编译和运行，效果相同，仅仅固定了数据内容，可通过`api/api_manager.dart`修改，其他不变，编译后请新建不同类型规则并保存，可获得app一致效果。

# LICENSE

[LICENSE](LICENSE)