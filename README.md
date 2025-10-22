# 🐶 dpipe_bruno_api_hub

This repository centralizes all **Bruno API collections** used across customer integrations.  
Each collection is organized by **customer name** and **integration type** (e.g., WooCommerce, Business Central, Magento, Amazon).  
The goal is to keep API testing consistent, credential-secure, and easy to maintain for all developers.

---
**Purpose:**  
This repo ensures that every developer working on client projects uses the exact same, secure, and standardized Bruno collections.

## Getting Started

### 1. Clone the Repository
### 2. Open Bruno

1. Install Bruno (when it is not installed) → [https://www.usebruno.com](https://www.usebruno.com)
2. In Bruno, click **Open Collection** and select the folder/project which you are working in.
3. Bruno will automatically recognize the structure and show the same tree view.

---

### Example for Choosing the Correct Collection

| Customer / Project | Path                     | Integrations                                          |
| ------------------ | -------------------------| ----------------------------------------------------- |
| **Default**        | `/default`               | Base collections for WooCommerce, BC, Magento, Amazon |
| **Carl Dietrich**  | `/carl_dietrich`         | WooCommerce + Business Central                        |
| **Wendt & Kühn**   | `/wendt_and_kuehn`       | Magento + Business Central                            |
| **default/wc**     | `/default/woo-commerce`  | When working with WooCommerce endpoints               |
---

## Environment Setup

Each collection has its own `environments/` folder containing file named `*.bru`.  
Use it to create your local environment safely.

---

## Credential Management Policy

- All API keys and secrets are stored in **1Password** 
- Local environments with live credentials are ignored via `.gitignore`.
- For shared access, contact your project's technical lead.

## Adding or Updating Collections

1. Export the latest **Postman collection** as **v2.1**. If you want to export environments also, you have to go to Environments tab and export it.
2. In Bruno, import it via **Collection → Import Collecion → Postman Collection**.
- Choose collection file
- Location: navigate to your local dpipe_bruno_api_hub (e.g in root folder or inside `default/`)
3. Now you can see a folder === collection name in local, which includes `environments/`, `bruno.json` and the `requests_file.bru` 
** every collection folder in bruno is considered as a workspace and has own environments. The `environments/`in root makes sense only when you are top admininistrator and have all rights to access to all projects.
4. If you want to import environments from Postman, then you have to import it manually in bruno.
- Go to the workplace you want to add environments
- From the top right of bruno, you can see environment select button -> **Configure -> Import Environment -> Postman Environment -> env_file**
- Here you can set secret values
5. In local repo, you can see some <request_files>.bru which content many sensible values eg. token, secret, etc. You have 2 ways to replace those sensitive values to `key` (token: {{token}})
- either run sanitize script:
`make sanitize` (for root)
`make sanitize folder=<specific_collection>` (for specific collection ex: make sanitize folder=default/business_central)
- or replace manually the value you consider that is sensible
** But for sure always read again the file
6. Add or update the corresponding `README.md` with documentation links.
7. Commit and push:
   ```bash
   git add .
   git commit -m "Update <Project> <Integration> collection"
   git push origin main
   ```

## **Best Practices:**
   - Use descriptive commit messages
   - Test your changes before committing
   - Keep environment-specific configurations separate
   - Document any new endpoints or significant changes

### Collaboration Guidelines
- Always pull the latest changes before making modifications
- Use feature branches for significant changes
- Review changes with team members before merging to main branch

## 🔒 Security Notes
⚠️ **Important Security Information:**
- **Environment secrets are NOT saved with their values** - You'll need to configure sensitive values (API keys, tokens, passwords) locally in your Bruno environment
- **Never commit sensitive credentials** - The `.git` folder is ignored by Bruno, but always double-check that no secrets are included in commits
- **Use environment variables** for all sensitive data like:
  - API keys
  - Authentication tokens
  - Database credentials
  - Private URLs

  **Set local environments in bruno** 
- By top right option button, click on 'Configure' button, there you can set secret values for few keys.
- To see all variables you set, click on the eye icon in brono (next to environment option button)

### Setting Up Secrets
1. Open your desired environment in Bruno
2. Add variables for sensitive data (e.g., `api_key`, `auth_token`)
3. Set their values locally - these will not be synced to the repository
4. Reference these variables in your requests using `{{variable_name}}`
