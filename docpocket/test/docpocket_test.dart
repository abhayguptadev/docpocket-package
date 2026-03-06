import 'package:flutter_test/flutter_test.dart';
import 'package:docpocket/docpocket.dart';

void main() {
  test('DocPocketFeature entry point test', () {
    // Testing if the entry point widget can be created without crashing
    final entryPoint = DocPocketFeature.getEntryPoint();
    expect(entryPoint, isNotNull);
  });
}
