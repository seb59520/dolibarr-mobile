import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Écrit le PDF dans `temp/` puis ouvre la sheet de partage natif
/// (`share_plus`). Cible mobile / desktop.
Future<void> sharePdfBytes(Uint8List bytes, String filename) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'application/pdf')],
    subject: filename,
  );
}
