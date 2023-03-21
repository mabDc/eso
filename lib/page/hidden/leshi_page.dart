import 'package:eso/api/analyzer_html.dart';
import 'package:eso/main.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

import 'linyuan_page.dart';

class LeshiPage extends StatelessWidget {
  LeshiPage({Key key}) : super(key: key);

  List<ArticleTitle> getArticleTitle(String html) {
    return AnalyzerHtml().parse(html).getElements("article").map((el) {
      final a = el.querySelector("a.daily-quote");
      final number = a.attributes["href"].split("/").last;
      return ArticleTitle(
          number, a.text.trim(), el.querySelector(".text-right").text.trim());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final titles = getArticleTitle(innerHtml);

    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(title: Text("乐事专用(仍在施工ing)")),
        body: ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            Card(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 24),
                  )),
            ),
            Divider(),
            Divider(),
            Divider(),
            Divider(),
            Divider(),
            Divider(),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 16),
              child: Text(
                '题头（废文）',
                style: TextStyle(fontSize: 24),
              ),
            ),
            if (titles.isEmpty)
              Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Text("获取中"),
                ),
              )
            else
              for (final title in titles)
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        InkWell(
                            onTap: () {
                              Utils.startPageWait(
                                  context,
                                  LaunchUrlWithWebview(
                                    url: "https://sosadfun.link/quote/${title.number}",
                                    title: "#${title.number}号题头",
                                    icon: "https://sosadfun.link/favicon.ico",
                                  ));
                            },
                            child: Row(children: [Text("#${title.number}"), Spacer()])),
                        Divider(),
                        Text(
                          "${title.content}",
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(children: [Spacer(), Text("${title.author}")]),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class ArticleTitle {
  final String content;
  final String number;
  final String author;
  const ArticleTitle(this.number, this.content, this.author);
}

final innerHtml = '''            <div class="carousel-inner">
                <div class="jumbotron item active" >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/227882" class="daily-quote">
                听说官方机构有海葬的服务，都是定点的。定……定点撒骨灰的话，洋流里人会不会太多啊（拘谨
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">阿muamua慕</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/234196" class="daily-quote">
                只要邻居家的猫猫去阳台吃猫粮，我家的猫就立马跟上，渐渐的，我的猫咪变成了猪咪，我才知道，原来邻居家有两只一样的猫猫
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——嘴不停的猪咪
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/60341" class="daily-quote">
                我没有义务去成全别人对我的期待。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——桃花太红李太白
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/231446" class="daily-quote">
                工作最有成就感的部分是辞职
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——马甲小鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/84203" class="daily-quote">
                她哪里是在书写，她简直是在爱抚那些文字。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">山阴先生</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/2134" class="daily-quote">
                文案选择转私密也可以用于修文。修好后再转公开，可避免施工现场暴露。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——咸鱼总部
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/25089" class="daily-quote">
                一个人怕寂寞，两个人怕辜负。
三个人斗地主，四个人打麻将。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/6451" class="daily-quote">
                发现被盗文的那一刻居然有种自己被出道的喜悦。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/231562" class="daily-quote">
                都市隶人。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——起来！不愿做奴隶的＿
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/29434" class="daily-quote">
                不是真的在贡献题头﹐而是向废文网背後的所有人致謝和打氣!!!!! 加油!
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">邪恶小可爱</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/231603" class="daily-quote">
                第一次收到陌生读者评论激动得呼吸和手抖，想怎么回复想了一夜，怕她觉得我高冷怕她觉得我无趣怕她觉得我神经怕她被我吓跑。呜呜。这个世界好善良，被人阅读好幸福。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——那你还不快去码字！
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/230191" class="daily-quote">
                他们好像永远都知道下一步该做什么，我不知道。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——流浪者
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/48579" class="daily-quote">
                健身吧朋友们，值得揍的人太多了
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">吃一口桃子</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/129271" class="daily-quote">
                医学生，学到哪儿觉得自己哪儿有病
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">豆本豆本豆</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/210693" class="daily-quote">
                各种我告诉妈妈的事，都变成了自她口出插入我胸口的利剑。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——无坚不摧
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/224601" class="daily-quote">
                想回味一部小说。打开收藏发现它消失了。打开记忆发现它的名字、作者都消失了。它成了一颗朱砂痣。我的心头已红透一片。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">何笃</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/167874" class="daily-quote">
                一条长题头，把我想看的编辑推荐推出二里地
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">莫掌柜</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/1" class="daily-quote">
                新的一天啊，依然没什么长进呢，但是我还没有放弃哟♥
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——咸鱼总部
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/224598" class="daily-quote">
                我填饱小狗的胃，小狗填饱我的心。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——喜欢小狗
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/227898" class="daily-quote">
                即便已经过去三年，我也已经上岸，我依然对2019年那个因为不会使用而失效的邀请码感到愧疚。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/234811" class="daily-quote">
                我养的花枝鼠都是很聪明听话的。她们知道什么事情我不允许做，于是她们会非常心虚地偷偷做。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">鲸式比格犬</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/192013" class="daily-quote">
                算了，我也没多重要。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">尤尤尤里子</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/194976" class="daily-quote">
                是我孤立了他们
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/224560" class="daily-quote">
                腰疼去医院检查，我：腰肌劳损是不是？医生：腰椎间盘突出。我：可是我才24。医生：看你这CT像84。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">猷扦</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/229266" class="daily-quote">
                好像有鱼鱼在找“妈，我想要这个”的题头，看见你好多次，刚刚刷到那个题头了，编号是93445。:D
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——Penguine
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/179758" class="daily-quote">
                一直以为真朋友难寻，直到发现大家都有那种存在好几年的几个人的小群，哦，原来只是对我来说难寻。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/225058" class="daily-quote">
                感谢废文tv，感谢论坛tv，感谢匿名tv，感谢各路鱼鱼，谢谢你们在论坛帖子里倾诉喜怒哀乐，让我看到人生百态，时而赞叹观点独到文笔俱佳，时而感慨人情世故悲欢离合
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                    </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/231913" class="daily-quote">
                没有资本不要怕！让家里长辈教你贴膜，这样在桥头摆摊的时候，就有了祖传的优势。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/185102" class="daily-quote">
                “ 过分鼓吹和强调个人努力，会导致我们对那些不幸在竞争中失败的人的苛责。”
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/1087" class="daily-quote">
                像你们这种人，只能当咸鱼，而我，能当咸鱼王
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">蘑菇喵</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/59668" class="daily-quote">
                这几天楼上天天再放甄嬛传，我估计这就是我连续几天梦见自己变成太监的原因
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">栗子木</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/225681" class="daily-quote">
                我想跑，藏到水里面，有人的时候屏住呼吸，没人的时候吐泡泡。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">边小牙齿</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/231581" class="daily-quote">
                梦里的感觉就是莫名其妙又逻辑自洽。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">曲速4号</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/230087" class="daily-quote">
                啊啊啊啊！我就知道有这么一天(流泪)
非常喜欢收藏的那些更新的消息，结果我按了&#039;全部标记已读&#039;心好痛
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">葫芦纸团君</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/192430" class="daily-quote">
                靠回忆维持的友情能撑多久
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/226701" class="daily-quote">
                怎么会有人给自己的狗起名叫烤红薯啊，狗跑了，一堆人大喊:烤红薯！狗没找回来，卖烤红薯的大爷骑着三轮车过来了“要几个？”
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">有个坡坡</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/2110" class="daily-quote">
                可以新建清单，留下“心得”，便捷安利！
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——咸鱼总部
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/145762" class="daily-quote">
                不能提交题头的时候已经想好了，可以提交题头的时候发现全忘了。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/74107" class="daily-quote">
                床以外的都是远方，手够不到的都是他乡。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">凊水苑真寺</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/224435" class="daily-quote">
                给村委会帮忙登记资料时，发现一个八十周岁的奶奶的名字是“沛恋”。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/229783" class="daily-quote">
                如果世界是虚伪的话，操控我的玩家到底是谁，麻烦上点心，充点钱好吗
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">我不是小医</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/143701" class="daily-quote">
                为什么喜欢看虐文：生活中很多时候哭不出来，换一种方式哭出来也是一样的，虐文也有治愈功能。
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——<a href="#">释久远</a>
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>
<div class="jumbotron item " >
    <article>
        <div class="container-fluid">
                        <h2 class="display-1">
                <a href="https://sosadfun.link/quote/177033" class="daily-quote">
                被亲爸一巴掌扇在地上，苹果手表问我：你似乎摔的很厉害，需要帮助吗？
                </a>
            </h2>
            <div class="row">
                <div class="col-xs-8 col-xs-offset-2 text-right">
                                                                    ——匿名咸鱼
                                                            </div>
            </div>
                        <br>
            <div class="row">
                            <div class="text-center">
                    <a class="btn btn-md btn-success sosad-button" href="https://sosadfun.link/register" role="button">Register Today</a>
                </div>
                        </div>
        </div>
    </article>
</div>''';
