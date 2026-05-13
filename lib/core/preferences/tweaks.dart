import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Champs optionnels affichables sur une carte de facture (liste) et
/// en sous-titre du détail. Indépendants entre eux.
enum InvoiceCardField {
  client,
  dueDate,
  totalHt;
}

const _kDefaultInvoiceFields = <InvoiceCardField>{InvoiceCardField.client};

/// Snapshot des préférences visuelles éditables depuis la page Tweaks.
///
/// Persistées via `SharedPreferences` (non sensibles, indépendantes du
/// secure storage qui ne stocke que la clé API + URL serveur).
@immutable
class Tweaks extends Equatable {
  const Tweaks({
    this.dark = false,
    this.accent = AppTokens.accentTeal,
    this.font = FontFamilyChoice.geist,
    this.density = DensityChoice.regular,
    this.cardStyle = CardStyleChoice.flat,
    this.fabPosition = FabPosition.right,
    this.invoiceFields = _kDefaultInvoiceFields,
  });

  final bool dark;
  final Color accent;
  final FontFamilyChoice font;
  final DensityChoice density;
  final CardStyleChoice cardStyle;
  final FabPosition fabPosition;
  final Set<InvoiceCardField> invoiceFields;

  Tweaks copyWith({
    bool? dark,
    Color? accent,
    FontFamilyChoice? font,
    DensityChoice? density,
    CardStyleChoice? cardStyle,
    FabPosition? fabPosition,
    Set<InvoiceCardField>? invoiceFields,
  }) =>
      Tweaks(
        dark: dark ?? this.dark,
        accent: accent ?? this.accent,
        font: font ?? this.font,
        density: density ?? this.density,
        cardStyle: cardStyle ?? this.cardStyle,
        fabPosition: fabPosition ?? this.fabPosition,
        invoiceFields: invoiceFields ?? this.invoiceFields,
      );

  @override
  List<Object?> get props => [
        dark,
        accent,
        font,
        density,
        cardStyle,
        fabPosition,
        invoiceFields,
      ];
}

const _kDark = 'tweaks.dark';
const _kAccent = 'tweaks.accent';
const _kFont = 'tweaks.font';
const _kDensity = 'tweaks.density';
const _kCardStyle = 'tweaks.cardStyle';
const _kFab = 'tweaks.fabPosition';
const _kInvoiceFields = 'tweaks.invoiceFields';

/// Provider du store de préférences (instancié à app boot).
final sharedPreferencesProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());

/// Notifier qui charge les Tweaks au démarrage et les ré-écrit à chaque
/// mutation. Lit/écrit `SharedPreferences` directement (instance déjà
/// initialisée à `main()` via override).
class TweaksNotifier extends Notifier<Tweaks> {
  late final SharedPreferences _prefs;

  @override
  Tweaks build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return Tweaks(
      dark: _prefs.getBool(_kDark) ?? false,
      accent: Color(_prefs.getInt(_kAccent) ?? AppTokens.accentTeal.toARGB32()),
      font: _decodeEnum(
        _prefs.getString(_kFont),
        FontFamilyChoice.values,
        FontFamilyChoice.geist,
      ),
      density: _decodeEnum(
        _prefs.getString(_kDensity),
        DensityChoice.values,
        DensityChoice.regular,
      ),
      cardStyle: _decodeEnum(
        _prefs.getString(_kCardStyle),
        CardStyleChoice.values,
        CardStyleChoice.flat,
      ),
      fabPosition: _decodeEnum(
        _prefs.getString(_kFab),
        FabPosition.values,
        FabPosition.right,
      ),
      invoiceFields: _decodeInvoiceFields(
        _prefs.getStringList(_kInvoiceFields),
      ),
    );
  }

  Set<InvoiceCardField> _decodeInvoiceFields(List<String>? raw) {
    if (raw == null) return _kDefaultInvoiceFields;
    final out = <InvoiceCardField>{};
    for (final name in raw) {
      for (final v in InvoiceCardField.values) {
        if (v.name == name) out.add(v);
      }
    }
    return out;
  }

  Future<void> setDark({required bool value}) async {
    state = state.copyWith(dark: value);
    await _prefs.setBool(_kDark, value);
  }

  Future<void> setAccent(Color color) async {
    state = state.copyWith(accent: color);
    await _prefs.setInt(_kAccent, color.toARGB32());
  }

  Future<void> setFont(FontFamilyChoice f) async {
    state = state.copyWith(font: f);
    await _prefs.setString(_kFont, f.name);
  }

  Future<void> setDensity(DensityChoice d) async {
    state = state.copyWith(density: d);
    await _prefs.setString(_kDensity, d.name);
  }

  Future<void> setCardStyle(CardStyleChoice c) async {
    state = state.copyWith(cardStyle: c);
    await _prefs.setString(_kCardStyle, c.name);
  }

  Future<void> setFabPosition(FabPosition p) async {
    state = state.copyWith(fabPosition: p);
    await _prefs.setString(_kFab, p.name);
  }

  Future<void> toggleInvoiceField(InvoiceCardField f) async {
    final next = Set<InvoiceCardField>.from(state.invoiceFields);
    if (!next.add(f)) next.remove(f);
    state = state.copyWith(invoiceFields: next);
    await _prefs.setStringList(
      _kInvoiceFields,
      next.map((e) => e.name).toList(),
    );
  }

  T _decodeEnum<T extends Enum>(String? raw, List<T> values, T fallback) {
    if (raw == null) return fallback;
    for (final v in values) {
      if (v.name == raw) return v;
    }
    return fallback;
  }
}

final tweaksProvider = NotifierProvider<TweaksNotifier, Tweaks>(
  TweaksNotifier.new,
);
