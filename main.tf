# GCP Overview and Instructions
# https://cloud.google.com/iam/docs/configuring-workload-identity-federation#oidc



resource "random_id" "random" {
  byte_length = 4
}

resource "google_iam_workload_identity_pool" "default" {
  provider                  = google-beta
  project                   = var.project_id
  count                     = length(local.identity_providers) > 0 ? 1 : 0
  workload_identity_pool_id = "${var.prefix}-bootstrap"
}


resource "google_iam_workload_identity_pool_provider" "default" {
  provider = google-beta
  project  = var.project_id
  for_each = local.identity_providers
  workload_identity_pool_id = (
    google_iam_workload_identity_pool.default.0.workload_identity_pool_id
  )
  workload_identity_pool_provider_id = "${var.prefix}-bootstrap-${each.key}"
  attribute_condition                = (each.value.attribute_condition != null ? each.value.attribute_condition : each.value.default_attribute_condition)
  attribute_mapping                  = each.value.attribute_mapping
  oidc {
    # Setting an empty list configures allowed_audiences to the url of the provider
    allowed_audiences = (each.value.custom_settings.audiences != null ? each.value.custom_settings.audiences : each.value.allowed_audiences)
    # If users don't provide an issuer_uri, we set the public one for the plaform choosed.
    issuer_uri = (
      each.value.custom_settings.issuer_uri != null
      ? each.value.custom_settings.issuer_uri
      : try(each.value.issuer_uri, null)
    )
  }
}

resource "google_service_account" "gitlab-runner" {
  account_id   = "gitlab-runner-service-account"
  display_name = "Service Account for GitLab Runner"
}

resource "google_service_account_iam_binding" "gitlab-runner-oidc" {
  provider           = google-beta
  for_each           = local.identity_providers
  service_account_id = google_service_account.gitlab-runner.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    for member in each.value.principals :
    format(member,
      google_iam_workload_identity_pool.default.0.name
    )
  ]

}



