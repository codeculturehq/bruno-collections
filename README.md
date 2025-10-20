# 🐶Bruno Collections

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

Each collection has its own `environments/` folder containing a template file named `*_template.bru`.  
Use these templates to create your local environment safely.

### Steps

1. Duplicate the template file and rename it, e.g.
   ```
   WooCommerce_Default_Template.bru → WooCommerce_<yourname>.bru
   ```

2. Open it in Bruno and fill in your credentials from **1Password**.
   - `shop_domain`
   - `wc_consumer_key`
   - `wc_consumer_secret`

3. Never commit `.bru` files that contain real credentials.

---

## Credential Management Policy

- All API keys and secrets are stored in **1Password** 
- Local environments with live credentials are ignored via `.gitignore`.
- For shared access, contact your project's technical lead.

## Adding or Updating Collections

1. Export the latest **Postman collection** as **v2.1**.
2. In Bruno, import it via **File → Import → Postman Collection**.
3. Save the new `.bru` files inside the correct subfolder (`default/woocommerce/api_v3.0/`, `carl_dietrich/business_central/`, etc.).
4. Add or update the corresponding `README.md` with documentation links.
5. Commit and push:
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

  
### Setting Up Secrets
1. Open your desired environment in Bruno
2. Add variables for sensitive data (e.g., `api_key`, `auth_token`)
3. Set their values locally - these will not be synced to the repository
4. Reference these variables in your requests using `{{variable_name}}`
