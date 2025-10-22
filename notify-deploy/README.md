# Nimbloo Deploy Notifier

GitHub Action para enviar notificações automáticas de deploy via **Slack** e **Email** (AWS SES).

## 🚀 Features

- ✅ Notificações automáticas via **Slack** e **Email**
- ✅ Auto-detecção de **ambiente** (dev/hml/prd) baseado na branch
- ✅ Auto-detecção de **versão** do projeto (pom.xml ou package.json)
- ✅ Auto-detecção de **status** do deploy (success/failed)
- ✅ Templates de email responsivos e profissionais
- ✅ Links diretos para Dashboard AWS, Lambda e Logs do GitHub
- ✅ Suporta projetos Java (Maven) e Node.js (npm)
- ✅ Altamente configurável via inputs ou variáveis de repositório

---

## 📦 Uso Básico

### Adicione 2 steps após seu deploy:

```yaml
      # Seu deploy aqui
      - name: Deploy
        run: ./deploy.sh

      # ✅ Step 1: Baixar action
      - uses: actions/checkout@v4
        with:
          repository: Nimbloo/nimbloo-github-actions
          ref: v1
          path: .github/actions-temp

      # ✅ Step 2: Notificar
      - uses: ./.github/actions-temp/notify-deploy
        if: always()
```

**Pronto!** Auto-detecta:
- ✅ Projeto (nome do repositório)
- ✅ Ambiente (dev/hml/prd da branch)
- ✅ Versão (pom.xml ou package.json)
- ✅ Status (success/failed)

---

## ⚙️ Configuração

### 1. Configurar Variáveis do Repositório

Configure as seguintes variáveis em **Settings → Secrets and Variables → Actions → Variables**:

| Variável | Obrigatória? | Descrição | Exemplo |
|----------|--------------|-----------|---------|
| `SLACK_WEBHOOK_URL` | Opcional | Webhook do Slack para notificações | `https://hooks.slack.com/services/...` |
| `NOTIFICATION_EMAIL` | Opcional | Email para receber notificações | `deploy@nimbloo.ai` |
| `NOTIFICATION_EMAIL_FROM` | Opcional | Email remetente (verificado no SES) | `noreply@nimbloo.ai` |

**Nota:** Você pode configurar essas variáveis em nível de **repositório** ou **organização**.

---

### 2. Configurar AWS SES (para notificações por email)

Se você quiser receber notificações por email, configure o AWS SES:

1. **Verifique o email remetente no SES:**
   ```bash
   aws ses verify-email-identity --email-address noreply@nimbloo.ai
   ```

2. **Confirme no email** recebido da AWS

3. **(Opcional) Sair do Sandbox:**
   - Por padrão, SES está em modo Sandbox (só envia para emails verificados)
   - Para enviar para qualquer email: [Request Production Access](https://console.aws.amazon.com/ses/home#/account)

---

### 3. Configurar Webhook do Slack

1. Acesse [Slack API](https://api.slack.com/apps)
2. Crie um novo App ou use existente
3. Ative **Incoming Webhooks**
4. Crie um webhook para o canal desejado (ex: `#deploys`)
5. Copie a URL do webhook (ex: `https://hooks.slack.com/services/...`)
6. Configure no GitHub como variável `SLACK_WEBHOOK_URL`

---

## 📖 Exemplos de Uso

### Exemplo 1: Uso Básico (Auto-detecção)

```yaml
name: Deploy

on:
  push:
    branches: [master, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to AWS
        run: sam deploy --stack-name my-app-${{ env.STAGE }}

      - name: Checkout nimbloo-github-actions
        uses: actions/checkout@v4
        with:
          repository: Nimbloo/nimbloo-github-actions
          ref: v1
          path: .github/actions-temp
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Notify
        uses: ./.github/actions-temp/notify-deploy
        if: always()
```

---

### Exemplo 2: Customizando Parâmetros

```yaml
- name: Checkout nimbloo-github-actions
  uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp
    token: ${{ secrets.GITHUB_TOKEN }}

- name: Notify Deploy Success
  if: success()
  uses: ./.github/actions-temp/notify-deploy
  with:
    project_name: "DCR API"
    stage: "prd"
    version: "2.1.0"
    status: "success"
    stack_name: "nimbloo-dcr-prd"
    aws_region: "us-east-1"
```

---

### Exemplo 3: Notificações Separadas (Started/Success/Failed)

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Checkout nimbloo-github-actions
        uses: actions/checkout@v4
        with:
          repository: Nimbloo/nimbloo-github-actions
          ref: v1
          path: .github/actions-temp
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Notify - Deploy Started
        uses: ./.github/actions-temp/notify-deploy
        with:
          status: "started"

      - name: Deploy
        run: ./deploy.sh

      - name: Notify - Deploy Success
        if: success()
        uses: ./.github/actions-temp/notify-deploy
        with:
          status: "success"

      - name: Notify - Deploy Failed
        if: failure()
        uses: ./.github/actions-temp/notify-deploy
        with:
          status: "failed"
```

---

### Exemplo 4: Multi-Stage Deploy

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        stage: [dev, hml, prd]
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to ${{ matrix.stage }}
        run: sam deploy --stack-name my-app-${{ matrix.stage }}

      - name: Checkout nimbloo-github-actions
        uses: actions/checkout@v4
        with:
          repository: Nimbloo/nimbloo-github-actions
          ref: v1
          path: .github/actions-temp
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Notify
        uses: ./.github/actions-temp/notify-deploy
        if: always()
        with:
          stage: ${{ matrix.stage }}
```

---

### Exemplo 5: Com Mensagem Customizada

```yaml
- name: Checkout nimbloo-github-actions
  uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp
    token: ${{ secrets.GITHUB_TOKEN }}

- name: Notify with Custom Message
  uses: ./.github/actions-temp/notify-deploy
  with:
    custom_message: "🎉 Nova feature: Upload de imagens agora 50% mais rápido!"
```

---

## 🎨 Inputs Disponíveis

| Input | Obrigatório | Padrão | Descrição |
|-------|-------------|--------|-----------|
| `project_name` | ❌ | Nome do repositório | Nome do projeto exibido nas notificações |
| `stage` | ❌ | Auto-detect (branch) | Ambiente: `dev`, `hml`, `prd` |
| `version` | ❌ | Auto-detect (pom.xml/package.json) | Versão da aplicação |
| `status` | ❌ | Auto-detect (job status) | Status: `started`, `success`, `failed` |
| `stack_name` | ❌ | `{project}-{stage}` | Nome da stack CloudFormation |
| `aws_region` | ❌ | `us-east-1` | Região AWS |
| `slack_webhook_url` | ❌ | Var `SLACK_WEBHOOK_URL` | Webhook do Slack |
| `notification_email` | ❌ | Var `NOTIFICATION_EMAIL` | Email destino |
| `notification_email_from` | ❌ | Var `NOTIFICATION_EMAIL_FROM` | Email remetente |
| `custom_message` | ❌ | - | Mensagem adicional nas notificações |

---

## 🔍 Auto-Detecção

### Detecção de Ambiente (Stage)

A action detecta automaticamente o ambiente baseado na branch:

| Branch | Environment |
|--------|-------------|
| `master`, `main` | `prd` (Produção) |
| `staging`, `homolog` | `hml` (Homologação) |
| `develop`, `dev` | `dev` (Desenvolvimento) |
| Outras | `dev` |

**Override:** Use o input `stage` para forçar um ambiente específico.

---

### Detecção de Versão

A action busca a versão do projeto automaticamente:

**Para projetos Java (Maven):**
```xml
<!-- pom.xml -->
<version>1.2.0</version>
```

**Para projetos Node.js:**
```json
// package.json
{
  "version": "1.2.0"
}
```

**Override:** Use o input `version` para forçar uma versão específica.

---

### Detecção de Status

A action detecta o status do deploy automaticamente:

- `success` → Deploy concluído com sucesso
- `failed` → Deploy falhou
- `started` → Deploy iniciado (use manualmente)

**Override:** Use o input `status` para forçar um status específico.

---

## 📧 Exemplos de Notificações

### Slack - Deploy Success (prd)

```
🎉 Deploy Concluído com Sucesso

Project:      nimbloo-billing
Environment:  prd
Version:      1.1.0
Branch:       master
Actor:        danilo
Commit:       a1b2c3d

Stack:   nimbloo-billing-prd
Region:  us-east-1

[📊 Dashboard] [⚡ Lambda] [📋 Logs]
```

### Email - Deploy Success

Email HTML profissional com:
- ✅ Badge do ambiente (dev/hml/prd)
- ✅ Tabela com informações do deploy
- ✅ Botões para Dashboard AWS e Logs
- ✅ Design responsivo e moderno

### Email - Deploy Failed

Email de erro destacado com:
- ❌ Indicador visual de erro (borda vermelha)
- ⚠️ Alerta de ação necessária
- 🔍 Botão para ver logs de erro
- ❗ Informações completas do deploy falhado

---

## 🛠️ Troubleshooting

### Notificações não estão sendo enviadas

**Slack:**
1. ✅ Verifique se `SLACK_WEBHOOK_URL` está configurado
2. ✅ Teste o webhook manualmente:
   ```bash
   curl -X POST "$SLACK_WEBHOOK_URL" \
     -H 'Content-Type: application/json' \
     -d '{"text":"Teste de webhook"}'
   ```

**Email:**
1. ✅ Verifique se `NOTIFICATION_EMAIL` e `NOTIFICATION_EMAIL_FROM` estão configurados
2. ✅ Verifique se o email remetente está verificado no SES
3. ✅ Verifique se a AWS CLI está configurada no workflow (necessário para SES)
4. ✅ Verifique permissões IAM para `ses:SendEmail`

---

### Versão não detectada

Se a versão aparecer como `unknown`:
1. ✅ Certifique-se de fazer `checkout` do código antes de chamar a action
2. ✅ Verifique se `pom.xml` ou `package.json` existem no root
3. ✅ Use o input `version` manualmente:
   ```yaml
   with:
     version: ${{ env.MY_VERSION }}
   ```

---

### Ambiente detectado incorretamente

Se o ambiente for detectado errado:
1. ✅ Use o input `stage` para forçar:
   ```yaml
   with:
     stage: "prd"
   ```

---

## 📝 Changelog

### v1.0.0 (2025-01-22)
- ✨ Release inicial
- ✅ Suporte para Slack e Email (SES)
- ✅ Auto-detecção de ambiente, versão e status
- ✅ Templates HTML responsivos
- ✅ Suporte para Maven e npm

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o repositório
2. Crie uma branch: `git checkout -b feature/nova-feature`
3. Commit: `git commit -m 'Adiciona nova feature'`
4. Push: `git push origin feature/nova-feature`
5. Abra um Pull Request

---

## 📄 Licença

MIT License - Nimbloo © 2025

---

## 💡 Suporte

Problemas ou dúvidas? [Abra uma issue](https://github.com/Nimbloo/nimbloo-github-actions/issues)
