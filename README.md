# 特点

开源的多站点跨平台阅读器来啦！

支持多来源的自定义阅读器与播放器。

用 flutter 开发，全平台支持，支持 windows，安卓，ios，macos，linux，tv，6 个平台。

ps: 所有内容来自互联网，app 本身只是工具，不提供内容。

欢迎意见或建议，喜欢不妨点个 star。

### 亦搜

多种来源，有发现，可搜索

### 亦看

看文字，看小说，看图片，看壁纸，看漫画，看视频

### 亦闻

听故事，听有声，听音乐，听英语

### 亦你所想，亦你所能

更多功能由君发挥，待君开发。

# 功能列表

- 平台
  - [x] 安卓
  - [x] tv（大白版，感谢大白）
  - [x] ios（需要自签）
  - [x] windows（~~需安装 vc++运行库~~ 内置 3 个 dll，不需要额外安装）
  - [x] Linux（需 libsqlite3-dev）
  - [x] Macos
- 其他
  - [x] 首次进入显示版本信息
  - [x] 备份和恢复
  - [x] 自动备份
  - [x] webdav 备份与恢复
  - [x] webdav 规则分享与获取
  - [x] 界面自定义，多项设置可调整
  - [x] 主题颜色（自定义）
  - [x] 夜间模式（自动、手动）
  - [x] 字体修改（正文、界面）
  - [x] 更新书架章节(书架下拉刷新)
  - [x] 浏览历史
  - [ ] 章节自动检查(每天/每次)
  - [ ] 换源
- 搜索
  - [x] 按类型或全部搜索
  - [x] 并发数调整
  - [x] 精确搜索
  - [x] 搜索词历史记录
- 发现
  - [x] 二级发现列表
  - [x] 多种样式，优化视频、文字、图片显示
  - [x] 小分类可搜索、收缩
- 目录
  - [x] 支持多线路
  - [x] 支持二级目录
  - [x] 可选显示更新时间和封面
- 视频播放
  - [x] 音量、亮度手势
  - [x] 左右滑动调整进度
  - [x] 进度条拖拽
  - [x] 友好的提示
  - [x] 投屏：DLNA
  - [ ] 直播优化
  - [x] 后台播放
  - [x] 按画面比例缩放(自动，充满，16：9，4：3，9：16)
- 文字浏览
  - [x] 仿真翻页（苹果样式）
  - [x] 仿真翻页（安卓样式）
  - [x] 覆盖翻页
  - [x] 多栏排版
  - [x] 图文混排
  - [x] 宽屏多栏
  - [x] 自定义边距、行距、段距、缩进调整
  - [x] 亮度调整
  - [x] 屏幕常亮开关
  - [x] 预加载
  - [x] 使用缓存加速正文加载
  - [x] 章节快速拖拽
  - [x] 字体设置
  - [x] 字体颜色、背景颜色、背景图片（jpg、png 透明图片、gif 动图）
  - [x] 键盘控制
    - 上一页：方向键左、上、上一页`pageup`
    - 下一页：方向键右、下、下一页`pagedown`
    - 上一章：方括号左`[`、减号`-`、插入键`insert`或`ins`
    - 上一章：方括号右`]`、小键盘加号`+`、删除键`delete`或`del`
    - 菜单：回车`enter`
  - [x] tts
  - [ ] 音量翻页
- 图片查看
  - [x] 方向可选上到下、左到右、右到左
  - [x] 显示章节、系统信息
  - [x] 缩放
  - [x] 单独查看
  - [x] 进度条拖拽
  - [x] 图片保存
- 音频播放
  - [x] 单曲循环
  - [x] 歌单循环
  - [x] 搜索结果循环
  - [x] 后台播放
  - [x] 歌词（高亮、滚动、拖拽、播放）
- 规则
  - [x] 网络导入
  - [x] 剪贴板导入导出
  - [x] 分享
  - [x] 规则压缩编码
  - [x] 规则调试
  - [x] 规则排序
  - [x] 嗅探
  - [x] 多页
- 规则列表
  ```dart
      "@js:" // @js: code
      "|"
      "@css:" // @css:a, @css:a@href, @css:a@text
      "|"
      "@json:" // @json:$.books.*, @json:$.name
      "|"
      "@http:" // @http:, @http:/api/$result
      "|"
      "@xpath:" // @xpath://a, @xpath:/a/@href, @xpath: /a/text()
      "|"
      "@match:" // @match:http.*?jpg， @match:url\("?(.*?jpg)@@1
      "|"
      "@regex:" // @regexp:h3[\s\S]*?h3
      "|"
      "@regexp:" // @regexp:h3[\s\S]*?h3
      "|"
      "@filter:" // @filter:lrc, @filter:m3u8, @filter:mp3
      "|"
      "@replace:" // @replace:</?em>, @replace:(?=\d+)@@播放量
      "|"
      "@encode:" // @encode:utf8|gbk|md5|base64|hmac|sha|sha256|aes
      "|"
      "@decode:" // @decode:utf8|gbk|base64|hmac|sha|sha256|aes
      "|"
      "^", // 首规则用如下符号开头 $(jsonpath), /(xpath), :(正则)
  ```

# 编译指南

不同平台有些插件不兼容，准备了多个依赖文件列表，必要时可替换 yaml，macos 和 linux 编译需要 dev 分支，windows 需要 master 分支。

源码去除规则解析部分，但不影响编译和运行，效果相同，仅仅固定了数据内容，可通过`api/api_manager.dart`修改.

- 打包 Android

```bash
flutter build apk
flutter build apk --target-platform android-arm
flutter build apk --target-platform android-arm64
flutter build apk --target-platform android-x64
# 分隔包
flutter build apk --split-per-abi
flutter build apk --target-platform android-arm64 --split-per-abi
```

- 打包 ios

```bash
flutter build ios --release
# 再到xcode下进行打包
```

- 启用桌面应用开关

```bash
flutter config --enable-linux-desktop # to enable Linux.
flutter config --enablesh-macos-desktop # to enable macOS.
flutter config --enable-windows-desktop # to enable Windows.

flutter build windows -v
flutter build linux -v
flutter build macos -v
```

# 规则获取

规则仓库 [eso_source](https://github.com/mabDc/eso_source)

`https://github.com/mabDc/eso_source`

规则百科 [wiki](https://github.com/mabDc/eso_source/wiki)

`https://github.com/mabDc/eso_source/wiki`

# 更新日志

见文件 [CHANGELOG](CHANGELOG.md)

# 感谢

大白[yangyxd](https://github.com/yangyxd)(界面)

大古[DaguDuiyuan](https://github.com/DaguDuiyuan)(ios 和 macos 平台)

大吉[ekibun](https://github.com/ekibun)(windows 平台 c++代码)

人艰不拆(LOGO、详情页设计)

以及 flutter 众多开源项目和插件。

# LICENSE

仓库开源使用 GPL_v3 协议 [GPL_v3](LICENSE)

# 一些图片

首先是视频，支持 DLNA 投屏，有音量、亮度、进度调节的手势控制。

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
