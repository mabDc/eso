# text_composition

flutter 中文排版 分页 上下对齐 两端对齐 多栏布局

弃用 richText，使用 Canvas，精确定位绘图位置，消除字体对排版影响

# 视频与截图

### demo

### 视频 https://user-images.githubusercontent.com/19526331/112481313-d8258f00-8db1-11eb-8faf-d96a7188116a.mp4

<img src="https://user-images.githubusercontent.com/19526331/113877556-66a30300-97eb-11eb-8b01-825d5eb11662.jpg" width="200"> <img src="https://user-images.githubusercontent.com/19526331/113877580-6c004d80-97eb-11eb-9561-c93be18a15b2.jpg" width="200"> <img src="https://user-images.githubusercontent.com/19526331/113876862-ba611c80-97ea-11eb-99db-169f7380514d.jpg" width="200"> <img src="https://user-images.githubusercontent.com/19526331/113876870-bd5c0d00-97ea-11eb-959e-c5cde58bec7d.jpg" width="200">

<img src="https://user-images.githubusercontent.com/19526331/113878095-e0d38780-97eb-11eb-801a-1b3c08a13f7d.jpg" width="200"> <img src="https://user-images.githubusercontent.com/19526331/113877800-a0740980-97eb-11eb-9ffe-ec83276e7f61.jpg" width="200"> <img src="https://user-images.githubusercontent.com/19526331/113877807-a23dcd00-97eb-11eb-99f5-973431a412b9.jpg" width="200"> <img src="https://user-images.githubusercontent.com/19526331/113877823-a4a02700-97eb-11eb-8c64-3a8f354a1d76.jpg" width="200">

<img src="https://user-images.githubusercontent.com/19526331/114257783-c3bdd500-99f4-11eb-9167-5c42c846f147.jpg" width="400"> <img src="https://user-images.githubusercontent.com/19526331/114257762-af79d800-99f4-11eb-9a47-6095cdd6e42f.jpg" width="400">

<img src="https://user-images.githubusercontent.com/19526331/114257767-b56fb900-99f4-11eb-8948-6d5aa4c51e3b.jpg" width="400"> <img src="https://user-images.githubusercontent.com/19526331/114257769-b86aa980-99f4-11eb-9f37-54a3a0bd95d6.jpg" width="400">

## LICENSE

[GPL-3.0 License](LICENSE)

## 特点

- [x] 中文英文符号混排两端对齐
- [x] 支持非等高字体
- [x] 支持非等宽字体
- [x] 按容器高度分页
- [x] 上下分散对齐
- [x] 多栏布局
- [x] 翻页切换动画
- [x] 页面阴影
- [x] 键盘响应
- [x] 支持标题`title`与样式`titleStyle`
- [x] 支持链接`link`和样式`linkStyle`
- [ ] `link`点击事件
- [ ] 图片

## example

`/example/lib/main.dart`

~~字体会影响显示效果~~

使用 canvas 绘图 不受字体影响 任意字体都可以上下对齐 两端对齐

`windows`自带字体效果（非等宽 非等高）

![image](https://user-images.githubusercontent.com/19526331/109809275-145a4980-7c63-11eb-8d5e-f3a8047b54f8.png)

`腾祥嘉丽.ttf`字体效果

![E3Z@FG25IXJ)I 6Y1(HDD$W](https://user-images.githubusercontent.com/19526331/109742072-5b1b5580-7c09-11eb-81d1-04e692424d35.png)

![$}C 5XZ6BHL_3X}HCSXHPGV](https://user-images.githubusercontent.com/19526331/109742094-666e8100-7c09-11eb-9c97-979a70c7222a.png)
