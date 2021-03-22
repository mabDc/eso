# text_composition

flutter 中文排版 分页 上下对齐 两端对齐 多栏布局

弃用richText，使用Canvas，精确定位绘图位置，消除字体对排版影响

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

使用canvas绘图 不受字体影响 任意字体都可以上下对齐 两端对齐

`windows`自带字体效果（非等宽 非等高）

![image](https://user-images.githubusercontent.com/19526331/109809275-145a4980-7c63-11eb-8d5e-f3a8047b54f8.png)


`腾祥嘉丽.ttf`字体效果

![E3Z@FG25IXJ)I 6Y1(HDD$W](https://user-images.githubusercontent.com/19526331/109742072-5b1b5580-7c09-11eb-81d1-04e692424d35.png)


![$}C 5XZ6BHL_3X}HCSXHPGV](https://user-images.githubusercontent.com/19526331/109742094-666e8100-7c09-11eb-9c97-979a70c7222a.png)
