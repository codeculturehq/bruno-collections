# Business Central - v2.1

Official Postman collection for WooCommerce REST API (v3).  
Contains product, order, and customer endpoints for default testing and integrations.

**Docs:** [BuninessCentral REST API](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/endpoints-apis-for-dynamics)  
**Auth:** Beare Token Auth (Token)  
**Environment Variables:** `base_url`, `company_id`, `client_id`,`client_secret` ,`tenant`

## Create credentials environments
- Create a  new file (*.bru) inside environments folder, which have same structure like **.bru.template
- Paste your credential (e.g: from 1Password) insise {{**}}

**If you have more credentials, then add more**. There is no fix template

### Do not push credentials!!
- Always check if any credential still in the files before committing and pushing 
