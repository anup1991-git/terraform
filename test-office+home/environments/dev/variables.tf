variable "subscription_id" {
    description = "The Subscription ID for the Azure account."
    type        = string
}

variable "client_id" {
    description = "The Client ID which should be used."
    type        = string
}

variable "client_secret" {
    description = "The Client Secret which should be used."
    type        = string
}

variable "tenant_id"{
    description = "The Tenant ID which should be used."
    type        = string
}

variable "password" {
  description = "The password to be stored in Key Vault."
  type        = string
  sensitive = true
}