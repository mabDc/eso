import 'dart:io';

setUpTestFiles(
  String appTestFilePath,
  String imageTestFilePath,
  String pdfTestFilePath,
  String yamlTestFilePath,
) {
  // .app files on macOS are actually directories but they are treated as files
  Directory(appTestFilePath).createSync();

  File(
    './test/test_files/franz-michael-schneeberger-unsplash.jpg',
  ).copySync(imageTestFilePath);
  File(
    './test/test_files/test.pdf',
  ).copySync(pdfTestFilePath);
  File(
    './test/test_files/test.yml',
  ).copySync(yamlTestFilePath);
}

tearDownTestFiles(
  String appTestFilePath,
  String imageTestFilePath,
  String pdfTestFilePath,
  String yamlTestFilePath,
) {
  Directory(appTestFilePath).deleteSync();
  File(imageTestFilePath).deleteSync();
  File(pdfTestFilePath).deleteSync();
  File(yamlTestFilePath).deleteSync();
}
