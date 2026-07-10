import 'package:flutter_test/flutter_test.dart';
import 'package:app_ramos_candidatura/app_config/app_widget.dart';

void main() {
  testWidgets('AppWidget carrega sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const AppWidget());
    await tester.pump();
    expect(find.byType(AppWidget), findsOneWidget);
  });
}
