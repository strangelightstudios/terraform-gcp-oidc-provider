variable "gitlab_url" {
  type    = string
  default = "https://gitlab.com"
}

variable "gitlab_project_id" {
  type        = string
  description = "Project ID to restrict authentication from."
  nullable    = false
}

variable "gitlab_repository" {
  type        = string
  description = "Project repository to restrict authentication from."
  nullable    = false
}

variable "gitlab_project" {
  type        = string
  description = "Project to restrict authentication from."
  nullable    = false
}
variable "gitlab_group" {
  type        = string
  description = "Project group to restrict authentication from."
  nullable    = false
}

variable "gitlab_branch" {
  type        = string
  description = "Project branch to restrict authentication from."
  nullable    = false
}

variable "project_id" {
  type = string
}

variable "prefix" {
  type = string
}

variable "federated_identity_providers" {
  description = "Workload Identity Federation pools. The `cicd_repositories` variable references keys here."
  type = map(object({
    attribute_condition = optional(string)
    issuer              = string
    custom_settings = optional(object({
      issuer_uri = optional(string)
      audiences  = optional(list(string), [])
    }), {})
  }))
  default  = {}
  nullable = false
  # TODO: fix validation
  # validation {
  #   condition     = var.federated_identity_providers.custom_settings == null
  #   error_message = "Custom settings cannot be null."
  # }
}
