output "management_group_id" {
  description = "Resource ID of the Planta Norte management group."
  value       = azurerm_management_group.planta.id
}

output "budget_name" {
  description = "Name of the Terraform-managed subscription budget."
  value       = azurerm_consumption_budget_subscription.lab.name
}
