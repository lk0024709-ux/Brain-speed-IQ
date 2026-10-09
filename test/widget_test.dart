import 'package:brain_speed_iq/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('home screen shows all training modes', (tester) async {
    await tester.pumpWidget(const BrainSpeedApp());
    await tester.pumpAndSettle();
    expect(find.text('BRAIN SPEED'), findsOneWidget);
    expect(find.text('REFLEX RUSH'), findsOneWidget);
    expect(find.text('MEMORY MATRIX'), findsOneWidget);
    expect(find.text('PATTERN BREAKER'), findsOneWidget);
  });

  testWidgets('a training mode can be opened', (tester) async {
    await tester.pumpWidget(const BrainSpeedApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('REFLEX RUSH'));
    await tester.pumpAndSettle();
    expect(find.text('START TRAINING'), findsOneWidget);
  });
}
