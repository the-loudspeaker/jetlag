import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jetlag/screens/shared/role_selection_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RoleSelectionScreen displays seeker and hider buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RoleSelectionScreen(),
      ),
    );

    expect(find.text('Select Your Role'), findsOneWidget);
    expect(find.text('SEEKER'), findsOneWidget);
    expect(find.text('HIDER'), findsOneWidget);
  });
}
