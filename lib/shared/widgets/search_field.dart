import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:dolibarr_mobile/core/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Champ de recherche avec debounce 300ms et bouton clear.
///
/// Émet via `onChanged` à chaque pause de 300ms ; émet immédiatement
/// au tap sur le bouton clear (chaîne vide).
class SearchField extends StatefulWidget {
  const SearchField({
    required this.onChanged,
    this.hintText = 'Rechercher…',
    this.initialValue,
    this.debounce = const Duration(milliseconds: 300),
    this.autofocus = false,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final String? initialValue;
  final Duration debounce;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _debouncer = Debouncer(delay: widget.debounce);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debouncer.run(() => widget.onChanged(value.trim()));
    setState(() {}); // refresh suffix icon
  }

  void _clear() {
    _controller.clear();
    _debouncer.cancel();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(LucideIcons.search, size: 20),
        suffixIcon: hasText
            ? IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: _clear,
                tooltip: 'Effacer',
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
        ),
      ),
    );
  }
}
