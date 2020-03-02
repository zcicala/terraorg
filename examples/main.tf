provider "okta" {
  # note: specify OKTA_ORG_NAME via environment
  # note: specify OKTA_BASE_URL via environment
  # note: specify OKTA_API_TOKEN via environment
}

provider "gsuite" {
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
  ]
  impersonated_user_email = "g.suite.admin@yourcompany.com"
}

terraform {
  backend "gcs" {
    bucket = "terraorg-state"
    prefix = ""
  }

  required_version = "~> 0.12.0"
}
