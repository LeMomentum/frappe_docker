# État des lieux & Plan de déploiement — Vooroo CRM

> Dernière mise à jour : 9 février 2026

### URLs de production

| Service | URL |
|---|---|
| **Landing page** | https://lemomentumtech.com |
| **CRM (après connexion)** | https://lemomentum.tech/vooroo_crm/ |
| **Frappe Mail** | https://mail.lemomentum.tech/ |

---

## 0. Features développées — Inventaire fonctionnel

### 0.1 Dashboard

- Page d'accueil avec KPIs et métriques clés
- Cartes de statistiques (prospects, deals, activités, revenus)
- Accès rapide aux modules principaux

### 0.2 Prospects

- **Vue Kanban** — Drag & drop entre colonnes de statut (New, Contacted, Nurturing, Qualified, Unqualified, Junk)
- **Vue Tableau** — Colonnes triables (Type, Nom, Email, Téléphone, WhatsApp, Statut, Température, Valeur, Propriétaire, Source)
- **Badges Température** — 🔥 Chaud, 🌡️ Tiède, ❄️ Froid
- **Formulaires de création** — Individuel et Entreprise
- **Panel de détails (Drawer)** — Onglets : Contacts, Qualification, Infos personnelles, Infos professionnelles, Infos commerciales
- **Timeline d'activités** — Historique chronologique lié au prospect
- **Notes** — Éditeur rich text
- **Import CSV** — Importer des prospects depuis un fichier CSV
- **Recherche & filtrage avancé** — Temps réel par statut, température
- **Actions en masse** — Multi-sélection, changement de statut/température/propriétaire, export
- **Conversion en Deal** — Transformer un prospect qualifié en deal pipeline
- **API Backend** : `vooroo_saas/api/prospect.py`

### 0.3 Deals / Pipeline

- **Vue Pipeline Kanban** — Étapes personnalisables (Qualifié, Contact établi, RDV planifié, Proposition faite, Négociation, Gagné/Perdu)
- **Vue Tableau** — Type, Prospect, Prochaine activité, Température, Statut, Produit, Valeur, Propriétaire
- **Vue Prévisionnel / Calendrier** — Prévisions mensuelles avec valeurs et probabilités
- **Panel de détails (Drawer)** — Infos commerciales, stats, participants
- **Flux de processus** — Progression visuelle en chevrons à travers les étapes
- **Gestion Gagné/Perdu** — Marquer avec raisons
- **Duplication** — Cloner un deal avec remise à zéro des dates
- **Gestion des participants** — Propriétaire, Contributeur, Observateur
- **Multi-pipeline** — Basculer entre différents pipelines de vente
- **KPI Dashboard** — Total deals, valeur totale, taux de conversion
- **Filtrage** — Par pipeline, étape, propriétaire, température, fourchette de valeur, date de clôture
- **Export** — CSV, Excel, PDF
- **Lien Deal → Prospect** — Liaison automatique
- **API Backend** : `vooroo_saas/api/deal.py`

### 0.4 Contacts

- **Personnes et Organisations** — Deux vues distinctes
- **Vue Tableau Personnes** — Prochaine activité, Nom, Coordonnées, Organisation, Deals fermés/actifs, Propriétaire
- **Vue Tableau Organisations** — Point focal, Coordonnées, Adresse, Deals fermés/actifs
- **Timeline de contact** — Historique chronologique (appels, emails, réunions, création de deal, notes)
- **Détection de doublons** — Détection automatique avec score de similarité
- **Fusion de doublons** — Résolution conflit champ par champ
- **Création Personne** — Genre, Nom, Email, Téléphone, WhatsApp, Profession, Organisation, Fonction, Niveau de pouvoir, Pays, Ville
- **Création Organisation** — Nom, Employés, Email, Téléphone, Site web, Secteur, CA, Localisation
- **Vue Détails** — Onglets : Informations, Activités, Deals, Emails, Fichiers, Notes, Historique
- **Import/Export** — CSV, Excel, vCard
- **Vue Grille/Cartes** — Affichage alternatif en cartes
- **Actions rapides** — Appeler, Email, WhatsApp, Planifier activité, Créer deal

### 0.5 Activités

- **Vue Liste** — Checkbox, Date d'échéance, Type, Deal, Priorité, Contact, Coordonnées, Durée, Organisation
- **Vue Calendrier** — Mois/Semaine/Jour/Agenda avec drag-drop
- **Types d'activité** — 📞 Appel, 🤝 Réunion, 🍽️ Déjeuner, 📧 Email, ☑️ Tâche, 📝 Note, 🏢 Visite, 💬 Suivi, 🎯 Autre
- **Niveaux de priorité** — Très haute, Haute, Moyenne, Basse, Aucune (avec badges couleur)
- **Sections** — En retard, Aujourd'hui, À venir, Récemment terminées
- **Création d'activité** — Type, Titre, Date/Heure, Durée, Lien Deal, Contacts, Organisation, Priorité, Lieu, Description, Rappels, Assigné à, Invités, Récurrence
- **Modal de complétion** — Résultat (Connecté, Pas de réponse, Messagerie, etc.), notes, durée réelle, planifier suivi
- **Rappels** — 15 min, 30 min, 1h, 1 jour avant
- **Gestion des retards** — Indicateurs visuels et alertes
- **Actions en masse** — Marquer terminé, changer priorité, réassigner, supprimer, exporter
- **Recherche temps réel** — Sur titre, description, contact, deal, notes

### 0.6 Facturation

- **Devis (Quotation)** — Création depuis Prospect/Deal avec auto-remplissage client
- **Factures** — Création depuis Deal ou Devis avec auto-remplissage
- **Lignes de facture** — Produits/services avec quantités et prix
- **Numérotation automatique** — Séquence factures/devis
- **Multi-devises** — FCFA, USD, EUR
- **Conversion Devis → Facture** — Transformation directe
- **Suivi des paiements** — Statut Payé/Non payé
- **Envoi par email** — Envoi direct depuis l'interface
- **Export PDF** — Génération de factures PDF
- **Paramètres de facturation** — Infos entreprise, mentions légales, séries de numérotation, templates, conditions de paiement
- **Doctypes** : `vooroo_invoice`, `vooroo_invoice_item`, `vooroo_quotation`, `vooroo_quotation_item`
- **API Backend** : `vooroo_saas/api/quotation.py`, `vooroo_saas/api/invoice.py`

### 0.7 Email (intégré via Frappe Mail)

- **Configuration Email** — Compte, SMTP, signature, templates
- **Compositeur d'email** — Éditeur rich text avec To/CC/BCC, pièces jointes, templates
- **Historique d'emails** — Timeline de toutes les communications
- **Intégration** — Envoi de factures, propositions, suivis
- **Synchronisation IMAP** — Réception d'emails et réponses
- **API Backend** : `vooroo_saas/api/email.py`

### 0.8 Frappe Mail ✅ (Déployé et fonctionnel en production)

> 🌐 **https://mail.lemomentum.tech/**

- **Serveur de mail auto-hébergé** — Solution d'emailing complète basée sur Frappe
- **Déployé et fonctionnel** sur le VPS de production
- **Intégré avec le CRM Vooroo** — Envoi/réception d'emails depuis les modules Prospects, Deals, Contacts
- **Configuration via** le doctype `Vooroo Mail Settings` (SMTP/IMAP, 28 champs)

### 0.9 WhatsApp (via frappe_whatsapp)

- **Multi-compte** — Gestion de plusieurs comptes WhatsApp Business
- **Messagerie bidirectionnelle** — Envoi et réception avec suivi des conversations
- **Gestion de templates** — Création, synchronisation et gestion des templates avec Meta
- **WhatsApp Flows** — Formulaires interactifs avec builder visuel
- **Messages interactifs** — Boutons (max 3) et listes (max 10 items)
- **Envoi en masse** — Campagnes avec substitution de variables et suivi de progression
- **Médias** — Images, documents, vidéos, fichiers audio
- **Webhooks** — Réception en temps réel des messages et mises à jour de statut
- **Notifications déclenchées** — Sur événements DocType (Before/After Insert, Save, Submit, Cancel, Delete)
- **Interface Chat** — Messagerie directe depuis les fiches contacts
- **Doctypes** : `WhatsApp Account`, `WhatsApp Message`, `WhatsApp Template`, `WhatsApp Notification`, `WhatsApp Flow`, `Bulk WhatsApp Message`, etc.
- **API Backend** : `vooroo_saas/api/whatsapp.py`

### 0.10 Authentification & Onboarding

- **Inscription** — Création de compte avec vérification email
- **Connexion** — Authentification avec identifiants (page login custom `www/login.html`)
- **Vérification email** — Flux de validation avant activation
- **Réinitialisation de mot de passe** — Récupération de mot de passe oublié
- **Onboarding** — Assistant de configuration première connexion (entreprise, équipe)
- **Gestion de sessions** — Suivi des sessions actives
- **API Backend** : `vooroo_saas/api/user.py`, `vooroo_saas/api/permission.py`, `vooroo_saas/api/onboarding.py`

### 0.11 Mon Compte (connecté au backend)

- **Profil utilisateur** — Modifier prénom, nom, téléphone, date de naissance, rôle
- **Changement de mot de passe** — Validation ancien mot de passe + nouveau
- **Upload photo de profil** — Validation type/taille (JPG, PNG, GIF, WebP, max 5 MB)
- **Sessions actives** — Voir et révoquer les sessions (individuellement ou toutes)
- **Historique de connexion** — Date, IP, appareil, statut
- **Préférences de notifications** — Email, push, SMS (activable/désactivable)
- **Préférences d'interface** — Thème (clair/sombre), densité, format de date, ordre sidebar
- **Langue & région** — Langue, fuseau horaire, format de date
- **Préférences de travail** — Heures début/fin, jours travaillés, signature email
- **Services** : `profileService.js`, `sessionService.js`, `notificationService.js`, `uiPreferencesService.js`
- **Composable** : `useProfile.js`

### 0.12 Administration

- **Dashboard admin** — KPIs : Total utilisateurs, Utilisateurs actifs, Nombre de rôles
- **Gestion des utilisateurs** — Liste, création, édition, assignation de rôles, activation/désactivation
- **Gestion des rôles** — Création de rôles custom, assignation de permissions
- **Journal d'activité** — Audit trail complet des actions utilisateurs
- **Journal d'accès** — Historique login/logout, adresses IP
- **Gestion des permissions** — Permissions au niveau document et champ
- **API Backend** : `vooroo_saas/api/admin.py`, `vooroo_saas/api/permission.py`

### 0.13 Projets

- **Création de projet** — Depuis template ou de zéro
- **Vues multiples** — Kanban (par statut), Tableau, Gantt (timeline)
- **Phases de projet** — Organisation des tâches en phases
- **Tâches** — Création, assignation, suivi de complétion
- **Jalons** — Suivi d'événements importants
- **Équipe projet** — Assignation des membres
- **Templates de projet** — Structures réutilisables
- **Archivage** — Archiver les projets terminés

### 0.14 Temps réel & Notifications

- **Notifications temps réel** — Mouvements de deals, rappels d'activités, alertes de retard, deals gagnés/perdus
- **WebSocket** — Mise à jour en temps réel via `useRealtimeActivities.js`
- **Centre de notifications** — Vue unifiée de toutes les notifications
- **API Backend** : `vooroo_saas/api/notification.py`

### 0.15 Architecture technique frontend

| Couche | Détail |
|---|---|
| **Framework** | Vue 3 (Composition API) |
| **UI Library** | PrimeVue |
| **Design System** | Atomic Design (Atoms → Molecules → Organisms) |
| **State Management** | Composables Vue 3 (14 composables) |
| **Services API** | 13 services dédiés par module |
| **Routing** | Vue Router |
| **Build** | Vite |
| **Temps réel** | WebSocket via Frappe socketio |
| **Export** | CSV, Excel, PDF, vCard |

### 0.16 Doctypes custom créés (vooroo_saas)

| Doctype | Type | Module | Description |
|---|---|---|---|
| **Vooroo Invoice** | Standalone | Vooroo SaaS | Gestion des factures (statut, items, totaux, paiements) — 47 champs |
| **Vooroo Invoice Item** | Child Table | Vooroo SaaS | Lignes de facture (quantité, taux, taxe, remise) — 9 champs |
| **Vooroo Quotation** | Standalone | Vooroo SaaS | Gestion des devis (similaire à Invoice) — 45 champs |
| **Vooroo Quotation Item** | Child Table | Vooroo SaaS | Lignes de devis — 9 champs |
| **Vooroo Payment** | Standalone | Vooroo SaaS | Enregistrements de paiements liés aux factures — 8 champs |
| **Vooroo Mail Settings** | Singleton | Vooroo Saas | Configuration Frappe Mail/SMTP/IMAP — 28 champs |
| **Vooroo Email Template** | Standalone | Vooroo Saas | Templates d'emails avec variables dynamiques (Prospect, Deal, Invoice) — 10 champs |
| **Vooroo WhatsApp Config** | Standalone | Vooroo Saas | Configuration compte WhatsApp par utilisateur — 10 champs |
| **Vooroo Focal Point** | Child Table | Vooroo Saas | Points de contact au sein des organisations (nom, email, rôle, power_level) — 12 champs |

### 0.17 Extension du doctype CRM Lead (Frappe CRM) via Fixtures

L'app vooroo_saas **étend** le doctype `CRM Lead` de Frappe CRM via des fixtures (`custom_field.json` et `property_setter.json`).

#### Custom Fields ajoutés sur CRM Lead

| Champ | Type | Description |
|---|---|---|
| `custom_vooroo_section` | Section Break | Section regroupant les champs Vooroo |
| `custom_prospect_type` | Select | Type : Particulier / Entreprise |
| `custom_lead_label` | Data | Label personnalisé |
| `custom_whatsapp` | Data | Numéro WhatsApp |
| `custom_profession` | Data | Profession |
| `custom_power_level` | Data | Niveau de pouvoir décisionnel |
| `custom_residence_country` | Data | Pays de résidence |
| `custom_residence_city` | Data | Ville de résidence |
| `custom_hq_country` | Data | Pays du siège (entreprise) |
| `custom_hq_city` | Data | Ville du siège (entreprise) |
| `custom_company_email` | Data | Email entreprise |
| `custom_company_phone` | Data | Téléphone entreprise |
| `custom_acquisition_channel` | Data | Canal d'acquisition |
| `custom_attention_date` | Date | Date d'attention |
| `custom_requested_product` | Data | Produit demandé |
| `custom_expected_value` | Currency | Valeur attendue |
| `custom_expected_close_date` | Date | Date de clôture attendue |
| `custom_probability` | Percent | Probabilité de conversion |
| `custom_competitor` | Data | Concurrent identifié |
| `custom_focal_points` | Table | Points de contact (→ Vooroo Focal Point) |
| `custom_internal_notes` | Text | Notes internes |
| `custom_next_action` | Data | Prochaine action |
| `custom_next_action_date` | Date | Date prochaine action |
| `custom_deal_type` | Data | Type de deal |
| `custom_next_activity_type` | Data | Type prochaine activité |
| `custom_next_activity_date` | Date | Date prochaine activité |
| `custom_last_activity_date` | Date | Date dernière activité |

#### Property Setters (champs CRM Lead masqués)

Champs natifs du CRM Lead **cachés** car non pertinents pour Vooroo :

- SLA : `sla`, `sla_creation`, `sla_status`
- Temps de réponse : `response_by`, `first_response_time`, `first_responded_on`, `last_response_time`, `last_responded_on`
- Communication : `communication_status`, `rolling_responses`
- Facebook : `facebook_lead_id`, `facebook_form_id`
- Pricing natif : `products`, `total`, `net_total`
- Statut : `status_change_log`

### 0.18 Endpoints API Backend (vooroo_saas/api/)

| Fichier | Endpoints principaux |
|---|---|
| **prospect.py** | `get_prospect`, `create_prospect`, `update_prospect`, `delete_prospect`, `convert_to_deal`, bulk operations, import/export CSV, gestion activités (~47 endpoints) |
| **deal.py** | `get_deal`, `update_deal`, `update_deal_status`, `delete_deal`, pipeline stages, historique, commentaires, notes, fichiers (~25 endpoints) |
| **activity.py** | `add_activity`, `get_activities`, `complete_activity`, `get_deal_timeline` (avec version tracking) |
| **email.py** | Intégration SMTP, envoi/réception emails, gestion templates |
| **whatsapp.py** | `get_conversations`, `get_messages`, `get_templates`, `mark_as_read`, lier conversation aux enregistrements (~8 endpoints) |
| **quotation.py** | `get_quotations`, `get_quotation`, `create_quotation`, `delete_quotation`, `create_from_prospect`, `create_from_deal`, `convert_to_invoice` |
| **user.py** | `get_user_profile`, récupération infos utilisateur |
| **admin.py** | `get_users`, gestion utilisateurs/rôles, journaux d'activité |
| **permission.py** | `has_app_permission` (vérification d'accès) |
| **notification.py** | API de notifications |
| **onboarding.py** | Workflow d'onboarding |

### 0.19 Routing & Pages web (hooks.py)

| Route | Cible | Description |
|---|---|---|
| `/` | `index` (Landing SPA) | Page d'accueil / Landing page |
| `/inscription` | Landing SPA | Inscription |
| `/login` | Landing SPA | Connexion |
| `/verify-email` | Landing SPA | Vérification email |
| `/onboarding` | Landing SPA | Onboarding |
| `/reset-password` | Landing SPA | Réinitialisation mot de passe |
| `/vooroo_crm/<path>` | CRM SPA | Application CRM (après connexion) |
| `/app-admin` | Desk Frappe | Accès au desk Frappe (au lieu de `/app`) |

> **Architecture SPA** : Deux applications Vue.js distinctes —
> `public/landing/` (pages publiques) et `public/frontend/` (CRM authentifié)

---

## 1. État des lieux — Environnement de développement (Dev Container)

### 1.1 Architecture Docker

| Service | Image | Rôle |
|---|---|---|
| `frappe` | `frappe/bench:latest` | Container principal (bench dev) |
| `mariadb` | `mariadb:11.8` | Base de données |
| `redis-cache` | `redis:alpine` | Cache |
| `redis-queue` | `redis:alpine` | File d'attente / Socketio |

**Fichier compose** : `.devcontainer/docker-compose.yml`
**Workspace** : `/workspace/development` (monté depuis `..:/workspace:cached`)

### 1.2 Versions des composants

| Composant | Version | Branche | Source |
|---|---|---|---|
| **Frappe** | v15.99.0 | `version-15` | `https://github.com/frappe/frappe.git` |
| **CRM** | v1.58.5 | `main` | `https://github.com/frappe/crm.git` |
| **vooroo_saas** | v0.0.1 | `main` | `git@github.com:LeMomentum/vooroo_saas.git` |
| **frappe_whatsapp** | v1.0.12 | `master` | `https://github.com/shridarpatil/frappe_whatsapp.git` |
| **mail** | dev | `dev-container` | `git@github.com:LeMomentum/frappe_docker.git` |
| **Node.js** | v24.12.0 | — | Via nvm dans le container |
| **Python** | 3.14.2 | — | Via pyenv dans le container |
| **MariaDB** | 11.8 | — | Image Docker |

### 1.3 Site Frappe

| Propriété | Valeur |
|---|---|
| **Nom du site** | `development.localhost` |
| **DB type** | MariaDB |
| **DB host** | `mariadb` (container) |
| **DB name** | `_54cc49b9a1aab38b` |
| **developer_mode** | `1` (activé) |
| **Mot de passe root DB** | `123` |

### 1.4 Apps installées sur le site

Fichier `sites/apps.txt` :

```
frappe
crm
vooroo_saas
frappe_whatsapp
```



### 1.5 Limites & Notes

| Point | Détail |
|---|---|
| **Mémoire container** | 1536 MB (limite docker-compose) |
| **Build frontend** | Nécessite `NODE_OPTIONS=--max-old-space-size=4096` sinon heap out of memory |
| **Ports exposés** | 8000-8005 (web), 9000-9005 (socketio) |
| **SSH keys** | Montées depuis `~/.ssh` de l'hôte vers `/home/frappe/.ssh` |
| **GitHub Actions** | `deploy.yml` désactivé (manual dispatch only) |

### 1.6 Repos Git

| App | Remote | URL |
|---|---|---|
| frappe | `upstream` | `https://github.com/frappe/frappe.git` |
| crm | `origin` | `https://github.com/frappe/crm.git` |
| vooroo_saas | `origin` | `git@github.com:LeMomentum/vooroo_saas.git` |
| frappe_whatsapp | `origin` | `https://github.com/shridarpatil/frappe_whatsapp.git` |
| mail | `origin` | `git@github.com:LeMomentum/frappe_docker.git` |

---

## 2. Plan de déploiement sur VPS (Production)

### 2.0 Prérequis VPS

- Docker & Docker Compose installés
- Le repo `frappe_docker` cloné (avec `images/custom/Containerfile`)
- DNS `*.lemomentumtech.com` pointant vers le VPS
- Port 80 et 443 ouverts

### 2.1 Étape 1 — Créer le fichier `apps.json`

Créer le fichier `apps.json` à la racine du projet sur le VPS :

```json
[
  {
    "url": "https://github.com/frappe/crm.git",
    "branch": "main"
  },
  {
    "url": "https://github.com/LeMomentum/vooroo_saas.git",
    "branch": "main"
  },
  {
    "url": "https://github.com/shridarpatil/frappe_whatsapp.git",
    "branch": "master"
  }
]
```

> ⚠️ Si `vooroo_saas` est un repo **privé**, utiliser un Personal Access Token :
> `https://<GITHUB_TOKEN>@github.com/LeMomentum/vooroo_saas.git`

### 2.2 Étape 2 — Build de l'image custom

```bash
cd /home/frappe/frappe_docker

export APPS_JSON_BASE64=$(base64 -w 0 apps.json)

docker buildx build \
  --build-arg APPS_JSON_BASE64=$APPS_JSON_BASE64 \
  --build-arg FRAPPE_BRANCH=version-15 \
  --build-arg PYTHON_VERSION=3.11.6 \
  --build-arg NODE_VERSION=20.19.2 \
  -t lemomentum/vooroo:latest \
  -f images/custom/Containerfile .
```

> Le build installe Frappe v15 + toutes les apps listées dans `apps.json` dans une seule image.

### 2.3 Étape 3 — Configurer l'environnement (`.env`)

Créer le fichier `.env` à la racine :

```env
# Image custom
CUSTOM_IMAGE=lemomentum/vooroo
CUSTOM_TAG=latest

# Base de données
DB_PASSWORD=<MOT_DE_PASSE_FORT>

# Let's Encrypt
LETSENCRYPT_EMAIL=contact@lemomentumtech.com

# Sites (format Traefik avec backticks)
SITES=`crm.lemomentumtech.com`

# Optionnel
FRAPPE_SITE_NAME_HEADER=crm.lemomentumtech.com
```

### 2.4 Étape 4 — Lancer la stack de production

```bash
docker compose \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.https.yaml \
  up -d
```

Cela démarre :
- **configurator** → configure le bench (redis, db)
- **backend** → Gunicorn (API / workers)
- **frontend** → Nginx (reverse proxy)
- **websocket** → Socket.IO
- **scheduler** → bench schedule
- **queue-short / queue-long** → workers
- **db** → MariaDB
- **redis-cache / redis-queue** → Redis
- **proxy** → Traefik (SSL Let's Encrypt)

### 2.5 Étape 5 — Créer le site et installer les apps

```bash
# Créer le site
docker compose exec backend \
  bench new-site crm.lemomentumtech.com \
  --mariadb-root-password=<DB_PASSWORD> \
  --admin-password=<ADMIN_PASSWORD>

# Installer les apps (dans l'ordre)
docker compose exec backend bench --site crm.lemomentumtech.com install-app crm
docker compose exec backend bench --site crm.lemomentumtech.com install-app vooroo_saas
docker compose exec backend bench --site crm.lemomentumtech.com install-app frappe_whatsapp

# Lancer les migrations
docker compose exec backend bench --site crm.lemomentumtech.com migrate

# Rebuild les assets (si nécessaire)
docker compose exec backend bench build
```

### 2.6 Étape 6 — Vérification

```bash
# Vérifier que le site répond
curl -I https://crm.lemomentumtech.com

# Vérifier les logs
docker compose logs -f backend
docker compose logs -f frontend
```

---

## 3. Procédure de mise à jour (déploiement continu)

### 3.1 Mise à jour manuelle

```bash
cd /home/frappe/frappe_docker

# 1. Rebuild l'image (récupère le dernier code de chaque app)
export APPS_JSON_BASE64=$(base64 -w 0 apps.json)
docker buildx build \
  --no-cache \
  --build-arg APPS_JSON_BASE64=$APPS_JSON_BASE64 \
  --build-arg FRAPPE_BRANCH=version-15 \
  --build-arg PYTHON_VERSION=3.11.6 \
  --build-arg NODE_VERSION=20.19.2 \
  -t lemomentum/vooroo:latest \
  -f images/custom/Containerfile .

# 2. Redémarrer les containers
docker compose \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.https.yaml \
  down

docker compose \
  -f compose.yaml \
  -f overrides/compose.mariadb.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.https.yaml \
  up -d

# 3. Migrer la base de données
docker compose exec backend bench --site crm.lemomentumtech.com migrate
```

### 3.2 Script de déploiement automatisé (`deploy.sh`)

Créer un script `deploy.sh` sur le VPS pour automatiser les étapes ci-dessus.
Ensuite, réactiver le workflow GitHub Actions `deploy.yml` pour déclencher `deploy.sh` via SSH après chaque push.

### 3.3 Sauvegarde avant mise à jour

```bash
# Backup du site
docker compose exec backend bench --site crm.lemomentumtech.com backup --with-files

# Les backups sont dans le volume `sites` sous sites/crm.lemomentumtech.com/private/backups/
```

---

## 4. Résumé des fichiers clés

| Fichier | Rôle |
|---|---|
| `images/custom/Containerfile` | Dockerfile pour l'image de production |
| `compose.yaml` | Compose principal (services backend/frontend/websocket/queues) |
| `overrides/compose.mariadb.yaml` | Ajoute MariaDB |
| `overrides/compose.redis.yaml` | Ajoute Redis |
| `overrides/compose.https.yaml` | Ajoute Traefik + Let's Encrypt SSL |
| `.env` | Variables d'environnement (image, mdp, sites) |
| `apps.json` | Liste des apps à inclure dans l'image custom |
| `.devcontainer/docker-compose.yml` | Stack de développement (dev container) |
| `.github/workflows/deploy.yml` | CI/CD — désactivé (manual dispatch only) |
