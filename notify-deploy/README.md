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

## 🎯 Uso Recomendado (com duração)

Para mostrar a duração do deploy nos emails:

```yaml
jobs:
  deploy:
    steps:
      # 1. Salvar timestamp de início
      - name: Save deploy start time
        id: deploy_start
        run: echo "timestamp=$(date +%s)" >> $GITHUB_OUTPUT

      # 2. Seus steps de deploy...
      - name: Deploy
        run: ./deploy.sh

      # 3. Enviar notificação (com duração)
      - name: Send Deployment Notifications
        uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
        if: always()
        with:
          project_name: "Billing"
          started_at: ${{ steps.deploy_start.outputs.timestamp }}
```

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
