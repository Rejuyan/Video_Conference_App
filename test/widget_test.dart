import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmeet/data/sources/local_storage.dart';
import 'package:vmeet/domain/providers/providers.dart';
import 'package:vmeet/main.dart';

void main() {
  testWidgets('VMeet App compilation and initial boot smoke test', (WidgetTester tester) async {
    // Seed standard mocked local preferences for the test environment
    SharedPreferences.setMockInitialValues({
      'user_display_name': 'Test User',
      'user_avatar_index': 2,
    });
    
    final sharedPreferences = await SharedPreferences.getInstance();
    final localStorage = LocalStorage(sharedPreferences);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageProvider.overrideWithValue(localStorage),
        ],
        child: const VMeetApp(),
      ),
    );

    // Verify that the VMeet App boots, resolves state, and mounts successfully
    expect(find.byType(VMeetApp), findsOneWidget);
  });
}
