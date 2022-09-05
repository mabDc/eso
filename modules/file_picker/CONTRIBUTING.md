# Contributing to File Picker

:+1: :tada: First off, thanks for taking the time to contribute to _File Picker_! :tada: :+1:

The following is a first version of guidelines for contributing to _File Picker_. Feel free to propose changes to this document in a pull request.

## Issue a Pull Request

* **Dart code only:** before creating a pull request, please **write unit tests** if you added changes to Dart code under `lib/` (Java/Objective-C code is currently not tested). Please ensure that the **code analysis** via `dart analyze` throws no errors. Please also make sure that your **code is formatted correctly** via `dart format`. You can take a look into our CI pipeline at `.github/workflows/main.yml` for further details. The CI pipeline is triggered automatically when you create a pull request on GitHub. All steps in our pipeline must run without errors.

* Please **update the package version** in `pubspec.yaml` and `CHANGELOG.md`. We use [semantic versionining (SemVer)](https://semver.org/). TL;DR: increase the patch version when your pull request contains a bug fix. Increase the minor version when a new feature is added. Breaking changes to _File Picker_'s public API should result in an increase in the major version.

* Please **update the changelog** in `CHANGELOG.md`. Add a new level two heading with the updated package version to the top of the document, e.g. `## major.minor.patch`. Below that, add another level four heading that notes the affected platform(s), e.g. `#### Desktop (Linux)` or `Android`, and describe your changes. If your pull request is associated to an issue, then please reference the issue. The changelog will be shown on https://pub.dev/packages/file_picker/changelog.
