module "gitlab-oidc" {
    source = "github.com/coactdev/terraform-gcp-oidc-provider"
    prefix = "gitlab"
    project_id = "my_gitlab_project"
    gitlab_project_id = 12345678
    gitlab_repository = "coact.dev/my_gitlab_project"
    gitlab_group = "coact.dev"
    gitlab_project = "my_gitlab_project"
    gitlab_branch = "main"
    federated_identity_providers = {
      gitlab-1 = {
        issuer = "gitlab"
      }
    }
}

