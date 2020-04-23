# dart-json-path
A implement of json path by dart, its functions is similar to [JsonPath](https://github.com/json-path/JsonPath)
## usage

```dart
import './json_path.dart';

JPath jPath = JPath.compile("$..book[*].title");
print(jPath.search(testMap));

```
