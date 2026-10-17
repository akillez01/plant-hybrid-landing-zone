resource "azurerm_consumption_budget_subscription" "lab" {
  name            = "budget-lab"
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = "2026-10-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 50
    threshold_type = "Actual"
    operator       = "GreaterThan"
    contact_emails = var.budget_alert_emails
  }

  notification {
    enabled        = true
    threshold      = 90
    threshold_type = "Forecasted"
    operator       = "GreaterThan"
    contact_emails = var.budget_alert_emails
  }
}
