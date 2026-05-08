import 'package:dolibarr_mobile/features/extrafields/domain/entities/extrafield_definition.dart';
import 'package:dolibarr_mobile/shared/widgets/extrafields_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _defs = <ExtrafieldDefinition>[
  ExtrafieldDefinition(
    entityType: 'thirdparty',
    fieldName: 'siret_secondaire',
    label: 'SIRET secondaire',
    type: ExtrafieldType.varchar,
  ),
  ExtrafieldDefinition(
    entityType: 'thirdparty',
    fieldName: 'vip',
    label: 'Client VIP',
    type: ExtrafieldType.boolean,
  ),
  ExtrafieldDefinition(
    entityType: 'thirdparty',
    fieldName: 'langue',
    label: 'Langue',
    type: ExtrafieldType.select,
    options: {'fr': 'Français', 'en': 'Anglais'},
  ),
  ExtrafieldDefinition(
    entityType: 'thirdparty',
    fieldName: 'effectif',
    label: 'Effectif',
    type: ExtrafieldType.integer,
    required: true,
  ),
];

Future<Map<String, Object?>?> _pumpForm(
  WidgetTester tester, {
  Map<String, Object?> initial = const {},
}) async {
  Map<String, Object?>? captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ExtrafieldsForm(
            definitions: _defs,
            initialValues: initial,
            onChanged: (v) => captured = v,
          ),
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('rend un champ par définition', (tester) async {
    await _pumpForm(tester);
    expect(find.text('SIRET secondaire'), findsOneWidget);
    expect(find.text('Client VIP'), findsOneWidget);
    expect(find.text('Langue'), findsOneWidget);
    expect(find.text('Effectif *'), findsOneWidget);
  });

  testWidgets('toggle boolean émet via onChanged', (tester) async {
    Map<String, Object?>? captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExtrafieldsForm(
              definitions: _defs,
              initialValues: const {},
              onChanged: (v) => captured = v,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(captured?['vip'], isTrue);
  });

  testWidgets('TextField varchar préremplit avec initialValues',
      (tester) async {
    await _pumpForm(tester, initial: {'siret_secondaire': 'XYZ123'});
    expect(find.widgetWithText(TextField, 'XYZ123'), findsOneWidget);
  });

  testWidgets('integer requis sans valeur → erreur de validation',
      (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ExtrafieldsForm(
                definitions: _defs,
                initialValues: const {},
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(formKey.currentState?.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Champ requis'), findsOneWidget);
  });

  testWidgets('liste vide → SizedBox.shrink', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExtrafieldsForm(
            definitions: const [],
            initialValues: const {},
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(SwitchListTile), findsNothing);
  });
}
