class DLNAActionResult<T> {
  bool success;
  String httpContent;
  String errorMessage;
  T result;

  DLNAActionResult();

  DLNAActionResult.error() {
    success = false;
    errorMessage = 'No DLNA device or parameter is invalid!';
  }

  @override
  String toString() {
    return 'DLNAActionResult {success: $success, httpContent: $httpContent, '
        'errorMessage: $errorMessage, result: $result}';
  }
}
