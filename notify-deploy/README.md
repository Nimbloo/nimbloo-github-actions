# Nimbloo Deploy Notifier

Notificações automáticas de deploy via Slack e Email (AWS SES) com branding Nimbloo.

## ✨ Recursos

- 🎨 **Branding Nimbloo**: cores corporativas (#642878, #502364, #F05A28) e mascote Mr. Shipper
- 📧 **Email HTML**: template profissional com gradiente e informações detalhadas
- 💬 **Slack**: notificações formatadas com blocos e botões
- ⏰ **Contexto completo**: timestamp, duração do deploy, mensagem do commit
- 🔍 **Auto-detecção**: projeto, ambiente, versão, status

## 🚀 Uso Básico

```yaml
- uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
  if: always()
```

Auto-detecta: projeto, ambiente (dev/hml/prd), versão (pom.xml/package.json), status.

## 🎯 Uso Recomendado (Notificação Completa de Pipeline)

Para melhor visibilidade do ciclo de vida do deploy, envie notificações no **início** e no **fim**:

```yaml
jobs:
  deploy:
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # 1. Salvar timestamp de início do deploy
      - name: Save deploy start time
        id: deploy_start
        run: echo "timestamp=$(date +%s)" >> $GITHUB_OUTPUT

      # 2. Notificar INÍCIO do deploy
      - name: Notify deploy started
        uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
        with:
          project_name: "Billing"
          status: "started"
          stack_name: ${{ env.STACK_PREFIX }}-${{ env.STAGE }}
          started_at: ${{ steps.deploy_start.outputs.timestamp }}
          slack_webhook_url: ${{ vars.SLACK_WEBHOOK_URL }}
          notification_email: ${{ vars.NOTIFICATION_EMAIL }}
          notification_email_from: ${{ vars.NOTIFICATION_EMAIL_FROM }}

      # 3. Seus steps de build e deploy...
      - name: Build and Deploy
        run: ./deploy.sh

      # 4. Notificar FIM do deploy (sucesso ou erro)
      - name: Notify deploy completed
        uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
        if: always()  # Sempre executa, mesmo em caso de falha
        with:
          project_name: "Billing"
          stack_name: ${{ env.STACK_PREFIX }}-${{ env.STAGE }}
          started_at: ${{ steps.deploy_start.outputs.timestamp }}
          slack_webhook_url: ${{ vars.SLACK_WEBHOOK_URL }}
          notification_email: ${{ vars.NOTIFICATION_EMAIL }}
          notification_email_from: ${{ vars.NOTIFICATION_EMAIL_FROM }}
```

**Benefícios:**
- 🟠 **Início**: Email/Slack com header laranja "Deploy Iniciado" - time sabe que o deploy começou
- 🟣 **Fim**: Email/Slack com header roxo/verde "Deploy Concluído" - mostra duração real calculada
- 📊 **Rastreabilidade**: Histórico completo do ciclo de vida de cada deploy
- ⏱️ **Monitoramento**: Útil para deploys longos - acompanhar progresso em tempo real

## ⚙️ Configuração Opcional

**Variables (Settings → Variables):**
- `SLACK_WEBHOOK_URL` → Webhook do Slack
- `NOTIFICATION_EMAIL` → Email destino
- `NOTIFICATION_EMAIL_FROM` → Email remetente (verificado no SES)

**AWS SES (para email):**
```bash
aws ses verify-email-identity --email-address noreply@nimbloo.ai
```

**Slack:** [Criar webhook](https://api.slack.com/apps) → Incoming Webhooks → Copiar URL

---

## 📖 Exemplos

**Com parâmetros customizados:**
```yaml
- uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
  with:
    project_name: "DCR API"
    stage: "prd"
    version: "2.1.0"
    custom_message: "Nova feature XYZ"
    started_at: ${{ steps.deploy_start.outputs.timestamp }}
```

**Notificações separadas (início e fim):**
```yaml
- uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
  with:
    status: "started"

- name: Deploy
  run: ./deploy.sh

- uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
  if: success()
  with:
    status: "success"
```

---

## 🎨 Inputs

Todos opcionais (auto-detecta se não passar):

- `project_name` → Nome do projeto (padrão: nome do repo)
- `stage` → dev/hml/prd (padrão: da branch - master=prd, staging=hml, develop=dev)
- `version` → Versão (padrão: pom.xml ou package.json)
- `status` → started/success/failed (padrão: job status)
- `stack_name` → Stack CloudFormation
- `aws_region` → Região AWS (padrão: us-east-1)
- `custom_message` → Mensagem adicional
- `started_at` → **NOVO!** Timestamp de início (epoch) para calcular duração

---

## 📊 Informações Mostradas no Email

### Dados do Deploy
- ✅ Project name, version, stack, region
- 🌿 Branch e commit (com link)
- 👤 Deployed by (usuário GitHub)
- ⏰ **Timestamp**: data/hora exata do deploy
- ⏱️ **Duration**: tempo total do deploy (se `started_at` fornecido)

### Contexto
- 💬 **Commit message**: mensagem do último commit para contexto

### Ações Rápidas
- 📊 Dashboard CloudWatch
- 📋 Logs do GitHub Actions

---

## 🛠️ Troubleshooting

**Notificações não chegam:**
- Slack: Verifique `SLACK_WEBHOOK_URL` configurado
- Email: Verifique `NOTIFICATION_EMAIL`, `NOTIFICATION_EMAIL_FROM` configurados + email verificado no SES

**Versão não detectada:**
- Certifique-se que `pom.xml` ou `package.json` existe
- Ou passe manualmente: `version: "1.0.0"`

**Duração aparece como "N/A":**
- Adicione o step que salva o timestamp no início do job
- Passe o parâmetro `started_at` para a action

**Mr. Shipper não aparece no email:**
- Certifique-se que está usando a versão @v1 mais recente
- A imagem é hospedada no GitHub: deve aparecer automaticamente

**Issues:** https://github.com/Nimbloo/nimbloo-github-actions/issues

---

## 📊 Como Funciona - Fluxo de Notificações

```
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS WORKFLOW                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  1. Deploy Start │
                    │   (timestamp)    │
                    └──────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│           NOTIFY-DEPLOY ACTION (status: "started")              │
├─────────────────────────────────────────────────────────────────┤
│  🎯 Auto-detect:                                                │
│     • Project name (from repo)                                  │
│     • Stage (develop → dev, staging → hml, master → prd)        │
│     • Version (pom.xml or package.json)                         │
│                                                                 │
│  📱 SLACK:                                                      │
│     • Emoji: 🚀 Deploy Iniciado                                 │
│     • Fields: Environment, Version, Branch, Actor, Commit       │
│     • Context: "Deploy em progresso..." + link logs             │
│                                                                 │
│  📧 EMAIL:                                                      │
│     • Header: Gradiente LARANJA (#F05A28)                       │
│     • Title: "🚀 Deploy Iniciado!"                              │
│     • Badge: Cor por ambiente (dev=roxo, hml=laranja, prd=roxo)│
│     • Info: Project, Version, Branch, Actor, Timestamp          │
│     • Button: "Acompanhar Deploy" (link logs)                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  2. Build/Deploy │
                    │   (seus steps)   │
                    └──────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│      NOTIFY-DEPLOY ACTION (status: auto-detect or "failed")     │
├─────────────────────────────────────────────────────────────────┤
│  ⏱️  Calcula Duração:                                           │
│     • current_time - started_at = duration                      │
│     • Formato: "3m 45s" ou "25s"                                │
│                                                                 │
│  ✅ SE SUCCESS:                                                 │
│     📱 SLACK:                                                   │
│        • Emoji: ✅ (dev/hml) ou 🎉 (PROD!)                      │
│        • Fields: + Duration, Stack, Region                      │
│        • Buttons: Dashboard, Lambda, Logs                       │
│                                                                 │
│     📧 EMAIL:                                                   │
│        • Header: Gradiente ROXO (#642878 → #502364)             │
│        • Title: "✅ Deploy Concluído!" (🎉 em PRD)              │
│        • Info: + Stack, Region, Duration                        │
│        • Buttons: Dashboard, Logs                               │
│                                                                 │
│  ❌ SE FAILED:                                                  │
│     📱 SLACK:                                                   │
│        • Emoji: ❌ Deploy Falhou                                │
│        • Color: Red (danger button style)                       │
│        • Message: "Ação necessária"                             │
│        • Button: "Ver Logs" (red)                               │
│                                                                 │
│     📧 EMAIL:                                                   │
│        • Header: Gradiente VERMELHO (#dc2626)                   │
│        • Title: "❌ Deploy Falhou"                              │
│        • Alert: Warning box "Ação Necessária"                   │
│        • Button: "Ver Logs de Erro"                             │
└─────────────────────────────────────────────────────────────────┘
```

### 🎨 Lógica dos Emojis e Cores

| Status    | Ambiente      | Emoji Slack | Emoji Email | Cor Header Email     | Motivo                          |
|-----------|---------------|-------------|-------------|----------------------|---------------------------------|
| started   | Todos         | 🚀          | 🚀          | 🟠 Laranja (#F05A28) | Deploy em andamento             |
| success   | dev/hml       | ✅          | ✅          | 🟣 Roxo (#642878)    | Deploy normal concluído         |
| success   | **PRD**       | **🎉**      | **🎉**      | 🟣 Roxo Escuro       | **Produção merece comemoração!**|
| failed    | Todos         | ❌          | ❌          | 🔴 Vermelho (#dc2626)| Erro - ação necessária          |

#### 🎉 Por que emoji diferente em Produção?

```javascript
// No código:
if [ "$STAGE" == "prd" ]; then
  EMOJI="🎉"  // Festa! É produção!
else
  EMOJI="✅"  // Check mark simples
fi
```

**Motivo:**
- Deploy em **produção é um evento especial** que afeta usuários reais
- Emoji 🎉 **destaca visualmente** mensagens críticas de PRD no Slack
- Ajuda o time a **identificar rapidamente** deploys de produção vs desenvolvimento
- **Comemoração merecida** quando tudo funciona em PRD! 🎊

#### 🎨 Cores dos Badges por Ambiente

```
DEV → Roxo   #642878 (Nimbloo Purple)
HML → Laranja #F05A28 (Nimbloo Orange)  
PRD → Roxo Escuro #502364 (Nimbloo Deep Purple)
```

### 🔧 Detalhes Técnicos de Implementação

#### 📱 Slack
- **Encoding UTF-8**: Salva payload em `/tmp/slack-payload.json` antes de enviar
  - **Por quê?** Usar `-d "{...}"` inline quebra encoding de emojis
- **Content-Type**: `application/json; charset=utf-8`  
- **Formato**: Slack Block Kit com `type: "mrkdwn"` para formatação
- **Backticks**: Campos técnicos (`dev`, `1.1.2`) aparecem como código inline

#### 📧 Email
- **Template**: HTML inline com CSS (sem arquivos externos)
- **Imagens**: Mr. Shipper hospedado no GitHub (URL pública, não base64)
- **Cores Nimbloo**:
  - Roxo: `#642878`
  - Roxo Escuro: `#502364`
  - Laranja: `#F05A28`
- **JSON**: Criado via `jq` e enviado para AWS SES
- **Encoding**: UTF-8 charset em Subject e Body HTML

---
