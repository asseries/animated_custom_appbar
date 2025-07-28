import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animated_custom_appbar/animated_custom_appbar.dart';

void main() {
  test('Widget exists', () {
    final appBar = AnimatedCustomAppBar(
      centerWidget: Text('Test'),
      children: const [],
    );
    expect(appBar.centerWidget, isNotNull);
  });
}
