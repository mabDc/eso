import 'package:audioplayers/audioplayers.dart';
import 'package:eso/database/search_item.dart';

class AudioStateEvent {
  final SearchItem item;
  final AudioPlayerState state;
  final bool playNext;

  const AudioStateEvent(this.item, this.state, {this.playNext});
}