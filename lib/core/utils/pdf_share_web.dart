import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Déclenche un téléchargement navigateur via une URL `Blob`.
///
/// L'API `Share` n'est pas universellement disponible côté desktop ;
/// un download direct est plus fiable et donne immédiatement un fichier
/// à l'utilisateur.
Future<void> sharePdfBytes(Uint8List bytes, String filename) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  try {
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';
    web.document.body!.append(anchor);
    anchor
      ..click()
      ..remove();
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
