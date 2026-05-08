# Architecture Decision Records (ADR)

Décisions structurantes prises pendant le développement du MVP. Les
ADR sont immuables — un changement de décision doit créer une nouvelle
ADR `Statut: superseded by NNNN`.

| #    | Titre                                                                | Statut   |
| ---- | -------------------------------------------------------------------- | -------- |
| 0001 | [Architecture applicative](0001-architecture.md)                     | accepté  |
| 0002 | [Design System (Direction B)](0002-design-system.md)                 | accepté  |
| 0003 | [Base de données locale (Drift)](0003-local-db.md)                   | accepté  |
| 0004 | [Offline-first via Outbox + Optimistic UI + Drafts](0004-offline-first.md) | accepté  |
| 0005 | [Cascade Outbox via dependsOnLocalId](0005-cascade-outbox.md)        | accepté  |
| 0006 | [Résolution de conflits via comparaison tms](0006-conflict-resolution.md) | accepté  |
| 0007 | [Authentification dual-mode](0007-auth-modes.md)                     | accepté  |
| 0008 | [Web online-only en v1.0](0008-web-online-only.md)                   | accepté  |
| 0009 | [Cascade Outbox multi-niveaux](0009-cascade-multi-level.md)          | accepté  |
| 0010 | [Workflow facture online-only](0010-invoice-workflow-online.md)      | accepté  |
