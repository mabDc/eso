import 'package:audioplayers/audioplayers.dart';
import 'package:eso/database/search_item.dart';

class AudioStateEvent {
  final SearchItem item;
  final AudioPlayerState state;

  const AudioStateEvent(this.item, this.state);
}