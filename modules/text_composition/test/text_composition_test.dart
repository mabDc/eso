import 'package:flutter_test/flutter_test.dart';

// import 'package:text_composition/text_composition.dart';

void main() {
  test('test number equal', () {
    print("start ${DateTime.now()}");
    var sum = 0.0; // sum = 1 + 1/2 + 1/3 + ...
    for (var i = 1; i < 10000; i++) {
      sum += 1 / i;
      final _ = (sum * i).round();
    }
    print("end   ${DateTime.now()}");
    expect(1, 1);
  });
}
