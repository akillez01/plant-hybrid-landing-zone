# Plant Hybrid Landing Zone: status do projeto

Atualizado em 16/10/2026. Este arquivo resume o que já foi feito, as decisões tomadas e o que falta, para continuar o trabalho no VS Code (inclusive com assistente de IA no terminal). Coloque-o na raiz do repositório; se usar o Claude Code, copie também como `CLAUDE.md` para ele carregar o contexto automaticamente.

## Objetivo

Projeto de portfólio para o processo seletivo da act digital (Analista de Infraestrutura, projeto BMW Manaus). Simula uma planta industrial on-prem conectada a uma landing zone Azure hub-spoke, toda em Terraform, com pipeline DevSecOps (Checkov, Semgrep, Trivy, OWASP ZAP), workloads em k3d via ArgoCD e observabilidade com Prometheus e Grafana. Empresa fictícia: **Planta Norte Manaus** (nunca usar nome ou marca da BMW).

Documentos de referência (claude.ai):

- Plano do projeto: https://claude.ai/code/artifact/222a688e-e600-477f-b089-14894a2fd65f
- Passo a passo em 12 fases: https://claude.ai/code/artifact/095579e6-632e-49f8-ade9-90f50367fcfc

## Ambiente

| Item | Valor |
|---|---|
| Máquina local | Ubuntu 24.04.4, 16 threads, KVM ok, 31 GB RAM |
| Virtualização local | KVM/libvirt (no lugar de Hyper-V) |
| Cluster local | k3d (no lugar de AKS, por custo) |
| Conta Azure | conta pessoal, tenant "Diretório Padrão" |
| Tenant ID | `c27caa2c-e51f-40ae-a791-e8d302b7e45a` |
| Subscription ID | `8e922cf2-1ec9-4ff7-81bd-edfcca3ef147` (Azure for Students) |
| Crédito | US$100, expira em 16/10/2027, sem cartão |
| Região | `canadacentral` (segunda opção: `northcentralus`) |
| Pasta local | `~/Documentos/PlantHibrid` |

IDs de tenant e assinatura não são segredos. Segredos (PSK do IPsec, chaves SSH, client secrets) nunca entram no Git.

## Decisões de arquitetura (viram ADRs em `docs/adr/`)

1. **Hub-spoke**: hub `10.10.0.0/16`, spoke prod `10.20.0.0/16`, spoke shared `10.30.0.0/16`, on-prem `192.168.50.0/24`.
2. **NVA com strongSwan + dnsmasq** (VM B1s, `10.10.1.4`) no lugar do VPN Gateway e do DNS Private Resolver, por custo.
3. **NSGs no lugar do Azure Firewall** em lab; em produção seria Azure Firewall.
4. **OIDC** do GitHub Actions para o Azure, sem client secret.
5. **k3d em vez de AKS** para workloads; o módulo AKS é escrito e validado só com `terraform plan`.
6. **DAST local** com ZAP em Docker, porque runner self-hosted em repositório público é risco.
7. **Região**: a oferta Azure for Students só permite `canadacentral`, `spaincentral`, `northcentralus`, `italynorth` e `southafricanorth` (policy da Microsoft "Allowed resource deployment regions"). Escolhida `canadacentral` por ter zonas de disponibilidade. Em produção seria `brazilsouth`, por latência e LGPD. A policy do projeto restringe ainda mais, a `canadacentral` e `northcentralus`, como guardrail.

## Concluído

- [x] Conta Azure pessoal criada e assinatura Azure for Students ativada no tenant próprio
- [x] Cloud Shell configurado (PowerShell, sessão efêmera, sem storage)
- [x] Teste de região: `brazilsouth` bloqueada; regiões permitidas identificadas
- [x] Tenant Root Group inicializado, com a assinatura dentro
- [x] Orçamento provisório `budget-lab-portal` (US$10/mês, alertas 50% real e 90% previsão)
- [x] Pré-requisitos da máquina local validados (KVM e memória)
- [x] Guia adaptado para Ubuntu e `canadacentral`

## Pendente, na ordem

### Fase 0: ferramentas (máquina local)
- [x] Instalar git, gh, az, terraform, kubectl, helm, k3d, docker, KVM/libvirt, VS Code
- [x] Sair e entrar na sessão (grupos `docker` e `libvirt`) e rodar o bloco de validação
- [x] MFA ativado na conta Azure (obrigatório para CLI e IaC com usuário)

Validação local realizada em 16/10/2026: ferramentas instaladas; daemon Docker e
libvirt acessíveis; grupos `docker` e `libvirt` ativos. Login interativo do Azure
CLI concluído com o tenant e a assinatura do projeto.

### Fase 2: repositório (máquina local)
- [x] `gh repo create plant-hybrid-landing-zone --public --clone --license mit`
- [x] Estrutura de pastas e `.gitignore` (state, tfvars, .terraform, chaves)
- [x] Proteção da `main` (PR obrigatório) e environment `production` com revisor

Repositório criado em https://github.com/akillez01/plant-hybrid-landing-zone
(público, licença MIT). A branch `main` contém o scaffold inicial; proteção e
environment `production` configurados: PR obrigatório com uma aprovação,
revisão obrigatória no environment por `akillez01`, limitado a branches
protegidas. A revisão própria está habilitada para este laboratório individual.
O PR #1 atualiza este status e aguarda aprovação de outra pessoa.

### Fase 3: state remoto e OIDC (Cloud Shell, PowerShell)
- [x] Redefinir `$SUB`, `$TENANT` e `$REPO = "akillez01/plant-hybrid-landing-zone"`
- [x] Storage do state em `canadacentral` (container com `--auth-mode key`)
- [x] App registration `gh-plant-lz` com três federated credentials (main, pull_request, environment production)
- [x] Papéis: Contributor na assinatura, Storage Blob Data Contributor no state, Management Group Contributor e Resource Policy Contributor no root MG
- [x] Em caso de `AuthorizationFailed` no root MG, habilitar temporariamente a opção no Entra e repetir as atribuições
- [x] Desativar a elevação de acesso após concluir as atribuições
- [x] `gh secret set` para AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID

Progresso em 16/10/2026: criado `rg-plant-lz-state` em `canadacentral`, com a
conta LRS `stplantlz8e922cf2` e o container privado `tfstate`. App/service
principal e as três credenciais OIDC criados; Contributor na assinatura e
Storage Blob Data Contributor no state atribuídos; secrets OIDC cadastrados no
GitHub. Após habilitar temporariamente o acesso elevado no Entra, também foram
atribuídos Management Group Contributor e Resource Policy Contributor ao root
MG. A elevação temporária foi desativada após as atribuições; os quatro papéis
do app OIDC permanecem atribuídos.

### Fase 4: governança em Terraform (`live/00-governance`)
- [x] Descobrir o nome exato da initiative CIS no tenant
- [ ] MG `mg-planta`, policies de regiões, tags obrigatórias (`owner`, `env`, `cost-center`) e CIS em auditoria
- [ ] Budget `budget-lab` via Terraform; depois apagar o `budget-lab-portal`

Initiative mais recente encontrada para o CIS Azure Foundations: `CIS Azure
Foundations v3.0.0` (`470a962c-86a0-433b-803a-3c176b5ce79c`, 53 policies).
Também existe `CIS Microsoft Azure Foundations Benchmark v2.0.0`; a v3.0.0 é a
versão escolhida para auditoria neste laboratório.

### Fase 5: pipeline de Terraform
- [ ] `terraform.yml` com tflint, Checkov, plan comentado no PR, apply com aprovação e detecção diária de drift

### Fase 6: rede hub-spoke e NVA (`live/10-connectivity`)
- [ ] Chave SSH, IP público de saída, variáveis no GitHub
- [ ] VNets, peering, route table, NSG, NVA B1s, zona privada `az.planta.lab`

### Fase 7: lab on-prem em KVM
- [ ] Rede isolada `labnet`, VMs `rtr01` (Ubuntu) e `dc01` (Windows Server eval)
- [ ] Túnel IPsec IKEv2 rtr01 ↔ nva01; AD `planta.lab`; DNS híbrido; testes ponta a ponta

### Fase 8 a 10: k3d, ArgoCD, observabilidade e app
- [ ] k3d + ArgoCD (app-of-apps)
- [ ] kube-prometheus-stack via ArgoCD
- [ ] API de telemetria, pipeline com Semgrep e Trivy, PR de promoção, ZAP local, rollback por `git revert`

### Fase 11: documentação e demo
- [ ] README, ADRs, `docs/controls.md` (CIS → NIST CSF), vídeo de 5 minutos

## Armadilhas já conhecidas

- No guia, tudo entre `<` e `>` é marcador: substituir pelo valor, sem os sinais.
- Sessão do Cloud Shell é efêmera: variáveis somem ao reconectar.
- No Marketplace existem ofertas de terceiros com nomes como "Azure Cost Management" que pedem delegação de acesso (Azure Lighthouse). Usar sempre o serviço da Microsoft.
- Resource group não serve para testar região; a policy da oferta só bloqueia recursos reais.
- Resource providers precisam estar registrados (`Microsoft.Network`, `Microsoft.Compute`, `Microsoft.Storage`, `Microsoft.Management`, `Microsoft.PolicyInsights`, `Microsoft.Consumption`, `Microsoft.Insights`, `Microsoft.OperationalInsights`, `Microsoft.ContainerService`).
- Não rodar `sudo apt autoremove` sem conferir o driver NVIDIA ativo com `nvidia-smi`; a lista inclui pacotes do driver 535.
- Internet residencial com CGNAT: o túnel parte do lado on-prem (NAT-T, UDP 4500); se o IP de saída mudar, atualizar a variável `ONPREM_PUBLIC_IP` e o NSG.
- Encerrar cada sessão: `az vm deallocate` na NVA, `k3d cluster stop plant`, `virsh shutdown` nas VMs.
