# Nimbloo Deploy Notifier

Notificações automáticas de deploy via Slack e Email (AWS SES).

## 🚀 Uso

```yaml
- uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp

- uses: ./.github/actions-temp/notify-deploy
  if: always()
```

Auto-detecta: projeto, ambiente (dev/hml/prd), versão (pom.xml/package.json), status.

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
- uses: ./.github/actions-temp/notify-deploy
  with:
    project_name: "DCR API"
    stage: "prd"
    version: "2.1.0"
    custom_message: "Nova feature XYZ"
```

**Notificações separadas:**
```yaml
- uses: ./.github/actions-temp/notify-deploy
  with:
    status: "started"

- name: Deploy
  run: ./deploy.sh

- uses: ./.github/actions-temp/notify-deploy
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

---

## 🛠️ Troubleshooting

**Notificações não chegam:**
- Slack: Verifique `SLACK_WEBHOOK_URL` configurado
- Email: Verifique `NOTIFICATION_EMAIL`, `NOTIFICATION_EMAIL_FROM` configurados + email verificado no SES

**Versão não detectada:**
- Certifique-se que `pom.xml` ou `package.json` existe
- Ou passe manualmente: `version: "1.0.0"`

**Issues:** https://github.com/Nimbloo/nimbloo-github-actions/issues
