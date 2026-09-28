import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:harvesthub/main.dart';
import 'package:harvesthub/services/storage_service.dart';

void main() {
  testWidgets('HarvestHub app launches smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();

    await tester.pumpWidget(const HarvestHubApp());
    await tester.pumpAndSettle();

    expect(find.text('HarvestHub'), findsWidgets);
  });
}
