# Main
variable "okta_hub_org_name" {}
variable "okta_hub_base_url" {}
variable "okta_hub_api_token" {}
variable "okta_spoke_org_name" {}
variable "okta_spoke_base_url" {}
variable "okta_spoke_api_token" {}

locals {
  spoke_root_url          = format("https://%s.%s", var.okta_spoke_org_name, var.okta_spoke_base_url)
  spoke_authorization_url = format("%s/oauth2/default/v1/authorize", local.spoke_root_url)
  spoke_issue_url         = format("%s/oauth2/default", local.spoke_root_url)
  spoke_jwks_url          = format("%s/oauth2/default/v1/keys", local.spoke_root_url)
  spoke_token_url         = format("%s/oauth2/default/v1/token", local.spoke_root_url)
  spoke_user_info_url     = format("%s/oauth2/default/v1/userinfo", local.spoke_root_url)
}

module "hub" {
  source                         = "./modules/hub/sp"
  hub_org_name                   = var.okta_hub_org_name
  hub_base_url                   = var.okta_hub_base_url
  hub_api_token                  = var.okta_hub_api_token
  hub_spa_app_label              = "React SPA TF"
  hub_idp_name                   = "Spoke IDP TF"
  hub_idp_client_id              = module.spoke.web_application_client_id
  hub_idp_client_secret          = module.spoke.web_application_client_secret
  hub_idp_discovery_rule_name    = "Spoke Idp Rule TF"
  hub_idp_oidc_authorization_url = local.spoke_authorization_url
  hub_idp_oidc_issue_url         = local.spoke_issue_url
  hub_idp_oidc_jwks_url          = local.spoke_jwks_url
  hub_idp_oidc_token_url         = local.spoke_token_url
  hub_idp_oidc_user_info_url     = local.spoke_user_info_url
}

module "spoke" {
  source              = "./modules/spoke/idp"
  spoke_org_name      = var.okta_spoke_org_name
  spoke_base_url      = var.okta_spoke_base_url
  spoke_api_token     = var.okta_spoke_api_token
  spoke_oidc_app_name = "Spoke IDP TF"
}
terraform {
  required_version = "= 1.3.3"
}