import 'package:dolibarr_mobile/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DolibarrMobileApp affiche le placeholder Étape 1',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DolibarrMobileApp()),
    );
    // Premier frame.
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Étape 1 — Bootstrap'), findsOneWidget);
    // Le helloWorld dépend de la locale du système (FR ou EN). On vérifie
    // la présence d'au moins l'un des deux pour rester robuste.
    final helloFr = find.text('Bonjour Dolibarr Mobile');
    final helloEn = find.text('Hello Dolibarr Mobile');
    expect(
      helloFr.evaluate().isNotEmpty || helloEn.evaluate().isNotEmpty,
      isTrue,
      reason: 'Le message de bienvenue (FR ou EN) doit être affiché.',
    );
  });
}
