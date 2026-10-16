# Planta Norte Manaus — Hybrid Landing Zone

Projeto de portfólio para demonstrar uma landing zone Azure conectada a uma
planta industrial on-premises, com infraestrutura como código, DevSecOps,
workloads Kubernetes e observabilidade.

O ambiente é inteiramente fictício e não representa uma infraestrutura real.
Não use marcas ou nomes de fabricantes/empresas como identidade do projeto.

## Arquitetura

- Azure hub-spoke em `canadacentral`, provisionado com Terraform.
- NVA Linux com strongSwan e dnsmasq para conectividade e DNS híbrido.
- Laboratório on-premises isolado em KVM/libvirt.
- k3d local para workloads, ArgoCD e Prometheus/Grafana.
- GitHub Actions com verificações de segurança e implantação protegida.

Consulte [`STATUS.md`](STATUS.md) para decisões, andamento e próximos passos.
As decisões arquiteturais serão registradas em [`docs/adr/`](docs/adr/).

## Segurança

Não versione credenciais, chaves privadas, arquivos `.tfvars` ou state do
Terraform. O state remoto e a autenticação GitHub Actions/Azure devem usar
acesso controlado e OIDC; detalhes operacionais ficam fora do Git.

## Estrutura planejada

```text
.github/workflows/  Pipelines de Terraform e workloads
apps/               Aplicação de telemetria
docs/adr/           Registros de decisões arquiteturais
kubernetes/         Configuração do cluster e GitOps
live/               Ambientes Terraform implantáveis
modules/            Módulos Terraform reutilizáveis
```

## Status

O projeto está em bootstrap. Veja [`STATUS.md`](STATUS.md) antes de executar
qualquer provisionamento.
