import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestro_financas/main.dart';

void main() {
  testWidgets('App boots without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MaestroApp());
    // Aceita qualquer conteúdo — só garante que o app buildou
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
