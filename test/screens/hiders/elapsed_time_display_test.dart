import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetlag/screens/hiders/elapsed_time_display.dart';

void main() {
  testWidgets('ElapsedTimeDisplay shows elapsed time', (WidgetTester tester) async {
    final startTime = DateTime.now().subtract(const Duration(hours: 1, minutes: 5, seconds: 30));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElapsedTimeDisplay(startTime: startTime),
        ),
      ),
    );

    expect(find.text('Elapsed Time:'), findsOneWidget);
    expect(find.text('01:05:30'), findsOneWidget);
  });
}
