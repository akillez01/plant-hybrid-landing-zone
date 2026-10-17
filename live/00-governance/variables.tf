variable "subscription_id" {
  description = "Azure subscription containing the lab."
  type        = string
  default     = "8e922cf2-1ec9-4ff7-81bd-edfcca3ef147"
}

variable "tenant_id" {
  description = "Microsoft Entra tenant that owns the subscription."
  type        = string
  default     = "c27caa2c-e51f-40ae-a791-e8d302b7e45a"
}

variable "allowed_locations" {
  description = "Azure regions permitted for the lab."
  type        = set(string)
  default     = ["canadacentral", "northcentralus"]
}

variable "budget_amount" {
  description = "Monthly budget amount in USD."
  type        = number
  default     = 10

  validation {
    condition     = var.budget_amount > 0
    error_message = "The monthly budget amount must be greater than zero."
  }
}

variable "budget_alert_emails" {
  description = "Recipients for actual and forecasted budget notifications."
  type        = set(string)
  sensitive   = true
}
