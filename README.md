# Nimbloo GitHub Actions

Actions reutilizáveis para notificações de deploy via Slack e Email.

## 🚀 Como Usar

Adicione no final do seu workflow de deploy:

```yaml
- uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp

- uses: ./.github/actions-temp/notify-deploy
  if: always()
```

**Opcionais** - Configure se quiser Slack/Email (Settings → Variables):
- `SLACK_WEBHOOK_URL`
- `NOTIFICATION_EMAIL`
- `NOTIFICATION_EMAIL_FROM`

Auto-detecta: projeto, ambiente (dev/hml/prd), versão, status.

---

## 📖 Inputs Opcionais

Personalize passando inputs:

```yaml
- uses: ./.github/actions-temp/notify-deploy
  with:
    project_name: "Meu Projeto"
    stage: "prd"
    version: "1.0.0"
    custom_message: "Nova feature XYZ"
```

[📚 Documentação completa](./notify-deploy/README.md)

---

## 🛠️ Troubleshooting

**Permissões:** Organization Settings → Actions → General → Selecione "Allow Nimbloo, and select non-Nimbloo, actions..."

**Notificações não chegam:** Verifique se as variáveis estão configuradas e se o email remetente está verificado no AWS SES.

[📚 Mais detalhes](./notify-deploy/README.md)
