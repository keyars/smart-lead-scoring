import 'package:flutter_test/flutter_test.dart';
import 'package:smart_lead_scoring/main.dart';

void main() {
  testWidgets('renders lead scoring form', (tester) async {
    await tester.pumpWidget(const SmartLeadScoringApp());

    expect(find.text('Know which leads deserve attention.'), findsOneWidget);
    expect(find.text('Lead signals'), findsOneWidget);
    expect(find.text('Score this lead'), findsOneWidget);
    expect(find.text('Your score will appear here'), findsOneWidget);
  });
}
