# 🐶 dpipe_bruno_api_hub
Centralized Bruno API Collections for Customer Integrations
## 📋 Overview
This repository centralizes all **Bruno API collections** used across customer integrations. Each collection is organized by **customer name** and **integration type** (e.g., WooCommerce, Business Central, Magento, Amazon).

> **🎯 Goal:** Keep API testing consistent, credential-secure, and easy to maintain for all developers.

### 🚀 Purpose
This repo ensures that every developer working on client projects uses the exact same, secure, and standardized Bruno collections.

---

## 🏁 Getting Started

### Prerequisites
- Bruno API client ([Download here](https://www.usebruno.com))

### 1. Clone the Repository
### 2. Open Bruno

1. Install Bruno (when it is not installed) → [https://www.usebruno.com](https://www.usebruno.com)
2. In Bruno, click **Open Collection** and select the folder/project which you are working in.
3. Bruno will automatically recognize the structure and show the same tree view.

---

## 📁 Collection Structure

### Example for Choosing the Correct Collection

| Customer / Project | Path | Integrations |
|:-------------------|:-----|:-------------|
| **Default** | `/default` | Base collections for WooCommerce, BC, Magento, Amazon |
| **Carl Dietrich** | `/carl_dietrich` | WooCommerce + Business Central |
| **Wendt & Kühn** | `/wendt_and_kuehn` | Magento + Business Central |
| **Default/WC** | `/default/woo-commerce` | When working with WooCommerce endpoints |         |

---

## ⚙️ Environment Setup

Each collection has its own `environments/` folder containing file named `*.bru`.  
Use it to create your local environment safely. Ex:
```
collection-folder/
├── environments/
│   └── *.bru
├── bruno.json
└── requestsfile.bru/
```

> 💡 Naming principle: Use snake_case for all collection names.

---

## 🔐 Credential Management Policy

- All API keys and secrets are stored in **1Password** 
- Local environments with live credentials are ignored via `.gitignore`.
- For shared access, contact your project's technical lead.

--- 

## ➕ Adding or Updating Collections
### Step-by-Step Process

#### 1️⃣ Export from Postman
Export the latest **Postman collection** as **v2.1**. If you want to export environments also, navigate to the Environments tab and export it.

#### 2️⃣ Import to Bruno
In Bruno, import via:
```
Collection → Import Collection → Postman Collection
```
- Choose collection file
- Location: navigate to your local dpipe_bruno_api_hub (e.g., in root folder or inside `default/`)

#### 3️⃣ Review Structure
You'll see a folder (collection name) in local, which includes:
- `environments/`
- `bruno.json`
- `requests_file.bru`

> **📝 Note:** Every collection folder in Bruno is considered as a workspace and has own environments. The `environments/` in root makes sense only when you are top administrator and have all rights to access to all projects.

#### 4️⃣ Import Environments (Optional)
If importing environments from Postman:
1. Go to the workspace you want to add environments
2. From the top right of Bruno: **Environment Select → Configure → Import Environment → Postman Environment → env_file**
3. Set secret values here

#### 5️⃣ Sanitize Sensitive Data
Replace sensitive values with variables. You have 2 options:

**Option A: Run sanitize script**
```bash
# For root
make sanitize

# For specific collection
make sanitize folder=
# Example: make sanitize folder=default/business_central
```

**Option B: Manual replacement**
- Replace sensitive values manually with `{{variable_name}}`
- Example: `token: "abc123"` → `token: {{token}}`

> ⚠️ **Always review the file after sanitization!**

#### 6️⃣ Documentation
Add or update the corresponding `README.md` with documentation links.

#### 7️⃣ Commit and Push
```bash
git add .
git commit -m "Update   collection"
git push origin main
```

---

## **Best Practices:**

   - Use descriptive commit messages
   - Test your changes before committing
   - Keep environment-specific configurations separate
   - Document any new endpoints or significant changes

### Collaboration Guidelines
- Always pull the latest changes before making modifications
- Use feature branches for significant changes
- Review changes with team members before merging to main branch

---

## 🔒 Security Notes
⚠️ **Important Security Information:**
- **Environment secrets are NOT saved with their values** - You'll need to configure sensitive values (API keys, tokens, passwords) locally in your Bruno environment
- **Never commit sensitive credentials** - The `.git` folder is ignored by Bruno, but always double-check that no secrets are included in commits
- **Use environment variables** for all sensitive data like:
  - API keys
  - Authentication tokens
  - Database credentials
  - Private URLs

-  **Set local environments in bruno** 
- By top right option button, click on 'Configure' button, there you can set secret values for few keys.
- To see all variables you set, click on the eye icon in brono (next to environment option button)

### Setting Up Secrets
1. Open your desired environment in Bruno
2. Add variables for sensitive data (e.g., `api_key`, `auth_token`)
3. Set their values locally - these will not be synced to the repository
4. Reference these variables in your requests using `{{variable_name}}`

---

## 🪝 Git Hooks (Secret Protection)
To ensure no sensitive data is ever committed, a pre-commit hook is included.

1. Setup Hook (once per developer)

Run:
  ```bash
  # use make:
   make setup-hooks
# or maually in root:
   ./setup-hooks.sh
   ```
**Hook Behavior**

| Stage | Action |
|:------|:-------|
| **When committing** | Scans all staged `.bru` files (excluding `/environments/`) |
| **Blocks commit if** | Cleartext secrets are found (like `token: 12345abc`) |
| **Allows commit if** | Using masked placeholders (like `token: {{token}}`) |

### 🔍 Sensitive Keywords Detection

The hook automatically detects these patterns:
```
token|secret|password|passwd|pwd|apikey|api_key|credential|private|client_secret|access_key
```

**Adding New Sensitive Patterns**

If you encounter new patterns or custom variables:

1. **Open** `githooks/pre-commit`
2. **Add** new keyword(s) to `SENSITIVE_KEYWORDS=...`
3. **Save** and re-run your commit

> 💡 **Tip:** Always report newly found secret patterns to the team so they can be added to the global hook version.

---