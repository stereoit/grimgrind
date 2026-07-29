import 'package:chore_cash/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the chore catalog', (tester) async {
    await tester.pumpWidget(const GrimGrindApp());

    expect(find.text('KATALOG KARET'), findsOneWidget);
    expect(find.text('Vynést koš'), findsOneWidget);
    expect(find.text('Kronika'), findsOneWidget);
  });
}
