// ignore_for_file: lines_longer_than_80_chars
// Les chaînes longues de cette page sont du contenu d'aide utilisateur ;
// les couper artificiellement nuirait à la relecture.

import 'package:dolibarr_mobile/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginHelpPage extends StatelessWidget {
  const LoginHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Se connecter à votre Dolibarr'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceLg),
        children: [
          const _Intro(),
          const SizedBox(height: AppTokens.spaceLg),
          const _SectionTitle('Ce dont vous avez besoin'),
          const SizedBox(height: AppTokens.spaceSm),
          const _BulletList([
            'L’URL de votre instance Dolibarr (celle que vous tapez dans votre navigateur), par ex. https://erp.masociete.fr.',
            'Soit votre clé API personnelle (recommandé), soit votre identifiant + mot de passe Dolibarr.',
            'Une connexion Internet le temps de la première connexion. L’app fonctionne ensuite hors ligne pour les opérations courantes.',
          ]),
          const SizedBox(height: AppTokens.spaceXl),
          const _SectionTitle('Méthode 1 — Clé API (recommandé)'),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            'La clé API est plus sûre : elle ne contient pas votre mot de passe et peut être révoquée à tout moment depuis Dolibarr.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          const _SubTitle('Étape 1 — côté Dolibarr web'),
          const _NumberedList([
            'Connectez-vous à votre Dolibarr depuis un navigateur.',
            'Cliquez sur votre nom en haut à droite → « Carte d’utilisateur » (ou « Mon profil »).',
            'Ouvrez l’onglet « Authentification » (ou « Sécurité » selon la version).',
            'Dans la section « Clé pour API », cliquez sur « Générer/regénérer la clé API ».',
            'Copiez la longue chaîne de caractères qui s’affiche.',
          ]),
          const SizedBox(height: AppTokens.spaceSm),
          const _InfoBanner(
            icon: LucideIcons.info,
            message:
                'Si l’onglet ne s’affiche pas, demandez à votre administrateur Dolibarr d’activer le module REST API et de vous attribuer le droit « Utiliser l’API ».',
          ),
          const SizedBox(height: AppTokens.spaceMd),
          const _SubTitle('Étape 2 — côté app'),
          const _NumberedList([
            'Dans le champ URL de l’instance, tapez l’adresse de votre Dolibarr avec https:// au début.',
            'Sélectionnez le mode « Clé API ».',
            'Collez la clé API dans le champ.',
            'Appuyez sur « Tester la connexion » — un message vert « Connecté en tant que [votre nom] » doit apparaître.',
            'Appuyez sur « Se connecter » : vous arrivez sur le tableau de bord.',
          ]),
          const SizedBox(height: AppTokens.spaceXl),
          const _SectionTitle('Méthode 2 — Identifiants'),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            'Plus simple si vous n’avez pas accès à la clé API. Votre mot de passe n’est jamais stocké en clair, mais la méthode clé API reste préférable sur le long terme.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          const _NumberedList([
            'Tapez l’URL de votre instance.',
            'Sélectionnez le mode « Identifiants ».',
            'Tapez votre identifiant et mot de passe Dolibarr (les mêmes que pour le web).',
            '« Tester la connexion » puis « Se connecter ».',
          ]),
          const SizedBox(height: AppTokens.spaceXl),
          const _SectionTitle('Si la connexion échoue'),
          const SizedBox(height: AppTokens.spaceSm),
          const _DefinitionList([
            (
              term: 'Impossible de joindre l’instance',
              definition:
                  'Vérifiez l’URL (avec le https://) et que votre Dolibarr est accessible depuis Internet. Si l’accès est limité au réseau interne, activez votre VPN.',
            ),
            (
              term: 'Identifiants ou clé API invalides',
              definition:
                  'Vérifiez que vous avez bien copié la clé API en entier, ou retapez identifiant/mot de passe en respectant les majuscules.',
            ),
            (
              term: 'Erreur serveur',
              definition:
                  'Votre Dolibarr est en panne ou en maintenance. Réessayez plus tard ou contactez votre administrateur.',
            ),
          ]),
          const SizedBox(height: AppTokens.spaceXl),
          const _SectionTitle('Une fois connecté'),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            'Votre session est mémorisée : pas besoin de vous reconnecter au prochain lancement. La synchronisation se fait en arrière-plan ; vous pouvez consulter et modifier vos données même hors connexion — les changements seront poussés dès que le réseau revient.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            'Pour vous déconnecter : Paramètres → « Se déconnecter ».',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.spaceXl),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.helpCircle, color: theme.colorScheme.primary),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Text(
              'Ce guide vous accompagne pour relier l’app à votre instance Dolibarr en 2 minutes.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.spaceSm),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.spaceXs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6, right: 8),
                    child: Icon(Icons.circle, size: 6),
                  ),
                  Expanded(
                    child: Text(item, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NumberedList extends StatelessWidget {
  const _NumberedList(this.steps);
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.spaceSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${i + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(steps[i], style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DefinitionList extends StatelessWidget {
  const _DefinitionList(this.entries);
  final List<({String term, String definition})> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '« ${e.term} »',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(e.definition, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTokens.spaceSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppTokens.spaceSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
