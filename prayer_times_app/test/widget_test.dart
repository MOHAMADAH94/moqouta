import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_times_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App shows موقوتا', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PrayerTimesApp());
    await tester.pump();
    expect(find.text('موقوتا'), findsWidgets);
  });
}
