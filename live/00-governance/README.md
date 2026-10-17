# Governança

Root Terraform para `mg-planta`, políticas de localização, tags em recursos e
resource groups, CIS Azure Foundations v3.0.0 em modo de auditoria e o budget
mensal `budget-lab`.

O backend remoto usa a conta `stplantlz8e922cf2`, o container `tfstate` e o
arquivo `governance.tfstate`. Autentique localmente com Azure CLI ou, no GitHub
Actions, use OIDC. O principal precisa de `Storage Blob Data Contributor` no
storage e dos papéis de governança definidos em `STATUS.md`.

Para executar localmente, copie o exemplo de variáveis, substitua o endereço
de alertas e rode `terraform init`, `terraform validate` e `terraform plan`.
`terraform.tfvars` é ignorado pelo Git. Revise o plano antes de aplicar: o
primeiro apply move a assinatura para `mg-planta` e passa a avaliar as políticas
no escopo da assinatura.

Não remova `budget-lab-portal` até que `budget-lab` exista e os alertas tenham
sido verificados.
