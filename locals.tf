locals {
  identity_providers = {
    for k, v in var.federated_identity_providers : k => merge(
      v,
      lookup(local.identity_providers_defs, v.issuer, {})
    )
  }
  # settings takes preceds over var.federetadet_identity_providers
  identity_providers_defs = {
    # https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
    /*github = {
        attribute_mapping = {
          "google.subject"             = "assertion.sub"
          "attribute.sub"              = "assertion.sub"
          "attribute.actor"            = "assertion.actor"
          "attribute.repository"       = "assertion.repository"
          "attribute.repository_owner" = "assertion.repository_owner"
          "attribute.ref"              = "assertion.ref"
        }
        issuer_uri       = "https://token.actions.githubusercontent.com"
        principal_tpl    = "principal://iam.googleapis.com/%s/subject/repo:%s:ref:refs/heads/%s"
        principalset_tpl = "principalSet://iam.googleapis.com/%s/attribute.repository/%s"
        openid_configuration = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
      }*/
    # https://docs.gitlab.com/ee/ci/cloud_services/index.html#how-it-works
    # https://docs.gitlab.com/ee/ci/secrets/id_token_authentication.html#token-payload
    # https://docs.gitlab.com/ee/integration/openid_connect_provider.html
    gitlab = {
      attribute_mapping = {
        "google.subject"                  = "assertion.sub"
        "attribute.sub"                   = "assertion.sub"
        "attribute.aud"                   = "assertion.aud"
        "attribute.environment"           = "assertion.environment"
        "attribute.environment_protected" = "assertion.environment_protected"
        "attribute.namespace_id"          = "assertion.namespace_id"
        "attribute.namespace_path"        = "assertion.namespace_path"
        "attribute.pipeline_id"           = "assertion.pipeline_id"
        "attribute.pipeline_source"       = "assertion.pipeline_source"
        "attribute.project_id"            = "assertion.project_id"
        "attribute.project_path"          = "assertion.project_path"
        "attribute.repository"            = "assertion.project_path"
        "attribute.ref"                   = "assertion.ref"
        "attribute.ref_protected"         = "assertion.ref_protected"
        "attribute.ref_type"              = "assertion.ref_type"

        # Example of matching against protected tags
        "attribute.is_version_tag_push" = "assertion.ref_path.matches(R\"^refs/tags/v(\\d+\\.)?(\\d+\\.)?(\\*|\\d+)$\") && assertion.ref_protected == \"true\" ? \"true\" : \"false\""
      }
      allowed_audiences    = ["https://gitlab.com"] //TODO: check that this is being set
      issuer_uri           = "https://gitlab.com/"
      openid_configuration = "https://gitlab.com/.well-known/openid-configuration"
      principal_tpl = [
        format("principal://iam.googleapis.com/%%s/subject/project_path:%s:ref_type:branch:ref:%s", var.gitlab_repository, var.gitlab_branch),
        format("principal://iam.googleapis.com/%%s/subject/project_path:%s:ref_type:tag:ref:*", var.gitlab_repository)
      ]

      #principalset_tpl = "principal://iam.googleapis.com/%s/subject/project_path:%s:ref_type:tag:ref:%s"

      # The following principalset checks for protected tags
      principalset_tpl = "principalSet://iam.googleapis.com/projects/%%s/attribute.is_version_tag_push/true"

      principals                  = flatten([principal_tpl, principalset_tpl])
      default_attribute_condition = format("attribute.project_id==\"%s\"", var.gitlab_project_id)
    }
  }

  default_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}