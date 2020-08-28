import 'package:eso/api/analyze_url.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/utils/decode_body.dart';

import 'analyzer.dart';

class AnalyzerHttp implements Analyzer {
  String url;
  Rule _rule;

  AnalyzerHttp(Rule rule) {
    _rule = rule;
  }

  @override
  AnalyzerHttp parse(content) {
    if (content is List && content.length > 0) {
      url = '${content.first}';
    } else {
      url = '$content';
    }
    return this;
  }

  @override
  Future<String> getElements(String _) {
    return getString(_);
  }

  @override
  Future<String> getString(String _) async {
    final res = await AnalyzeUrl.urlRuleParser(url, _rule);
    return DecodeBody().decode(res.bodyBytes, null);
  }

  @override
  Future<String> getStringList(String _) {
    return getString(_);
  }
}
