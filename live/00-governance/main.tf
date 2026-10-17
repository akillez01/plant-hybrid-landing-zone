locals {
  root_management_group_id = "/providers/Microsoft.Management/managementGroups/${var.tenant_id}"
  required_tags            = toset(["owner", "env", "cost-center"])
}

resource "azurerm_management_group" "planta" {
  name                       = "mg-planta"
  display_name               = "Planta Norte Manaus"
  parent_management_group_id = local.root_management_group_id
}

resource "azurerm_management_group_subscription_association" "subscription" {
  management_group_id = azurerm_management_group.planta.id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed deployment regions"
  description          = "Restricts deployments to the approved lab regions."
  management_group_id  = azurerm_management_group.planta.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  parameters = jsonencode({
    effect = {
      value = "Deny"
    }
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })

  depends_on = [azurerm_management_group_subscription_association.subscription]
}

resource "azurerm_management_group_policy_assignment" "required_tags" {
  for_each = local.required_tags

  name                 = "require-${each.value}"
  display_name         = "Require tag: ${each.value}"
  description          = "Requires the ${each.value} tag on resources."
  management_group_id  = azurerm_management_group.planta.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })

  depends_on = [azurerm_management_group_subscription_association.subscription]
}

resource "azurerm_management_group_policy_assignment" "cis_azure_foundations" {
  name                 = "cis-azure-foundations-v3"
  display_name         = "CIS Azure Foundations v3.0.0 - Audit"
  description          = "Assesses the CIS Azure Foundations v3.0.0 initiative without enforcing its effects."
  management_group_id  = azurerm_management_group.planta.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/470a962c-86a0-433b-803a-3c176b5ce79c"
  enforce              = false

  depends_on = [azurerm_management_group_subscription_association.subscription]
}
