// Partage / téléchargement cross-platform d'un PDF en mémoire.
//
// L'import conditionnel sélectionne l'implémentation en fonction de la
// cible : web → déclenche un download navigateur (Blob + ancre HTML),
// mobile/desktop → écrit dans un fichier temp et appelle share_plus.
export 'pdf_share_io.dart' if (dart.library.js_interop) 'pdf_share_web.dart';
