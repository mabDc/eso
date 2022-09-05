class IllegalCharacterInFileNameException implements Exception {
  final String message;
  IllegalCharacterInFileNameException(this.message);
  @override
  String toString() => 'IllegalCharacterInFileNameException: $message';
}
