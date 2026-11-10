import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:tharpom_mx/main.dart';

void main() {
  testWidgets('muestra la demo de Tarpon y alterna el consejo', (tester) async {
    await tester.pumpWidget(const TarponApp());

    expect(find.text('Tarpon'), findsOneWidget);
    expect(find.byType(FCard), findsOneWidget);
    expect(find.text('Pesca deportiva en Ciudad del Carmen'), findsOneWidget);
    expect(
      find.text('Consejo: revisa el clima antes de salir a pescar.'),
      findsNothing,
    );

    await tester.tap(find.text('Ver consejo'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text('Consejo: revisa el clima antes de salir a pescar.'),
      findsOneWidget,
    );
    expect(find.text('Ocultar consejo'), findsOneWidget);

    await tester.tap(find.text('Ocultar consejo'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.text('Consejo: revisa el clima antes de salir a pescar.'),
      findsNothing,
    );
  });
}
