class TransportActions {
  static const String Play = "Play";
  static const String Stop = "Stop";
  static const String Pause = "Pause";
  static const String Seek = "Seek";
  static const String Next = "Next";
  static const String Previous = "Previous";
  static const String Record = "Record";

  List<String> actions;

  @override
  String toString() {
    return 'TransportActions {actions: ${actions.length}}';
  }
}
