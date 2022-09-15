import 'package:hive_flutter/hive_flutter.dart';
import 'package:text_composition/text_composition.dart';

import '../global.dart';

class TextConfigManager {
  static final _box = Hive.box(Global.textConfigKey);
  static TextCompositionConfig get config => TextCompositionConfig.fromJSON(_box.toMap().cast<String, dynamic>());
  static set config(TextCompositionConfig config) => _box.putAll(config.toJSON());
}
