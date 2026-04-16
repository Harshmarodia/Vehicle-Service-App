import 'package:flutter_test/flutter_test.dart';
import 'package:motobuddy_m/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MechanicHubApp(initialRoute: '/login'));
    await tester.pumpAndSettle();
    
    // Verify that the app builds without crashing.
    expect(find.byType(MechanicHubApp), findsOneWidget);
  });
}
