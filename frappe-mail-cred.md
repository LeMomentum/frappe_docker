 1. Frappe Mail ✅ Oui, fonctionnel

  ┌──────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────
  ─┐
  │ Info             │ Valeur                                                                                            
   │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────
  ─┤
  │ URL              │ https://mail.lemomentum.tech (ou http://109.199.103.177:8080 en interne)                          
   │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────
  ─┤
  │ API Key / Secret │ À générer depuis Frappe Mail : Settings > API Access > Generate Keys (voir doc FRAPPE_MAIL_API.md)

  ou - API Key & API Secret : à récupérer depuis Frappe Mail. Sur le VPS, 
  exécuter : # Depuis le container Frappe Mail
     bench --site mail.lemomentum.tech/ console
    
    Puis dans la console : keys = frappe.get_doc("User", 
  "Administrator").get_all_api_keys()
     # Ou créer une clé API dédiée :
     api_key, api_secret = frappe.generate_hash(), frappe.generate_hash()
   │
  └──────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────
  ─┘

  2. SMTP (envoi via Stalwart)

  ┌──────────────┬─────────────────────────────┐
  │ Info         │ Valeur                      │
  ├──────────────┼─────────────────────────────┤
  │ Serveur      │ mail.lemomentum.tech        │
  ├──────────────┼─────────────────────────────┤
  │ Port         │ 587 (STARTTLS) ou 465 (SSL) │
  ├──────────────┼─────────────────────────────┤
  │ Utilisateur  │ admin@lemomentum.tech       │
  ├──────────────┼─────────────────────────────┤
  │ Mot de passe │ admin123                    │
  └──────────────┴─────────────────────────────┘

  3. IMAP (réception via Stalwart)

  ┌──────────────┬─────────────────────────────┐
  │ Info         │ Valeur                      │
  ├──────────────┼─────────────────────────────┤
  │ Serveur      │ mail.lemomentum.tech        │
  ├──────────────┼─────────────────────────────┤
  │ Port         │ 993 (SSL) ou 143 (STARTTLS) │
  ├──────────────┼─────────────────────────────┤
  │ Utilisateur  │ admin@lemomentum.tech       │
  ├──────────────┼─────────────────────────────┤
  │ Mot de passe │ admin123                    │
  └──────────────┴─────────────────────────────┘
