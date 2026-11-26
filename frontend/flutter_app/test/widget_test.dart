import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guitar_songbook/main.dart';

void main() {
  testWidgets('Song search screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GuitarSongbookApp()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Find your next song'), findsOneWidget);
    expect(find.text('Popular Songs'), findsOneWidget);
  });
}
