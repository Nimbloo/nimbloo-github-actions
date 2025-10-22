# Nimbloo GitHub Actions

Coleção de GitHub Actions reutilizáveis para automação de deploy e notificações na Nimbloo.

## 📦 Actions Disponíveis

### [notify-deploy](./notify-deploy)

Envia notificações automáticas de deploy via Slack e Email (AWS SES).

**Instalação - 2 steps simples:**
```yaml
# Step 1: Baixar a action
- uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp

# Step 2: Usar
- uses: ./.github/actions-temp/notify-deploy
  if: always()
```

[📖 Ver documentação completa](./notify-deploy/README.md)

---

## 🚀 Quick Start

### Passo 1: Configurar variáveis (opcional)
Se quiser notificações Slack/Email, configure em **Settings → Secrets and Variables → Actions → Variables**:
- `SLACK_WEBHOOK_URL`
- `NOTIFICATION_EMAIL`
- `NOTIFICATION_EMAIL_FROM`

### Passo 2: Adicionar 2 steps no final do seu workflow

```yaml
      # Seu deploy aqui...
      - name: Deploy
        run: ./deploy.sh

      # ✅ Step 1: Baixar a action
      - uses: actions/checkout@v4
        with:
          repository: Nimbloo/nimbloo-github-actions
          ref: v1
          path: .github/actions-temp

      # ✅ Step 2: Enviar notificações
      - uses: ./.github/actions-temp/notify-deploy
        if: always()
```

**Pronto!** Auto-detecta ambiente, versão e status. Envia notificações Slack/Email automaticamente. 🎉

---

## 📚 Documentação

Cada action possui sua própria documentação detalhada:

- **[notify-deploy](./notify-deploy/README.md)** - Notificações de deploy (Slack + Email)

---

## 🔧 Desenvolvimento

### Estrutura do Repositório

```
nimbloo-github-actions/
├── README.md                    # Este arquivo
└── notify-deploy/               # Action de notificações
    ├── action.yml               # Definição da action
    └── README.md                # Documentação
```

### Versionamento

Este repositório usa **tags semânticas** para versionamento:

- `v1` → Última versão major 1 (recomendado)
- `v1.0.0` → Versão específica
- `master` → Desenvolvimento (não recomendado para produção)

**Uso recomendado:**
```yaml
# ✅ Recomendado - usa tag v1
ref: v1

# ✅ OK - versão fixa
ref: v1.0.0

# ⚠️ Não recomendado - desenvolvimento
ref: master
```

---

## 🤝 Como Usar em Seus Projetos

### 1. Configurar variáveis (opcional)
**Settings → Secrets and Variables → Actions → Variables:**
- `SLACK_WEBHOOK_URL` → URL do webhook Slack
- `NOTIFICATION_EMAIL` → Email para receber notificações
- `NOTIFICATION_EMAIL_FROM` → Email remetente (verificado no SES)

### 2. Adicionar no workflow

Abra `.github/workflows/deploy.yml` e adicione **no final**, após seu deploy:

```yaml
# Step 1: Baixar action
- uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp

# Step 2: Notificar
- uses: ./.github/actions-temp/notify-deploy
  if: always()
```

**Pronto!** No próximo deploy, receberá notificações automaticamente 🚀

---

## 📧 Exemplos de Notificações

### Slack

<img src="https://via.placeholder.com/400x200/3b82f6/ffffff?text=Slack+Deploy+Success" alt="Slack Notification" width="400"/>

### Email

<img src="https://via.placeholder.com/500x300/10b981/ffffff?text=Email+Deploy+Success" alt="Email Notification" width="500"/>

---

## 🛠️ Troubleshooting

### Action não encontrada

**Erro:**
```
Error: Unable to resolve action `Nimbloo/nimbloo-github-actions`
```

**Solução:**
Este erro ocorre quando se tenta usar a sintaxe direta (`uses: Nimbloo/...`) com repositórios privados.

**Use a abordagem com checkout explícito:**
```yaml
- name: Checkout nimbloo-github-actions
  uses: actions/checkout@v4
  with:
    repository: Nimbloo/nimbloo-github-actions
    ref: v1
    path: .github/actions-temp
    token: ${{ secrets.GITHUB_TOKEN }}

- name: Notify Deploy
  uses: ./.github/actions-temp/notify-deploy
  if: always()
```

### Permissões de acesso

Certifique-se que a organização permite o uso de actions privadas:
1. **Organization Settings** → **Actions** → **General**
2. Selecione: **"Allow Nimbloo, and select non-Nimbloo, actions and reusable workflows"**
3. Adicione as actions públicas permitidas (actions/*, aws-actions/*, codecov/*)

---

### Notificações não enviadas

Consulte o [Troubleshooting do notify-deploy](./notify-deploy/README.md#troubleshooting).

---

## 🚀 Roadmap

- [x] Action de notificações de deploy
- [ ] Action de teste automatizado
- [ ] Action de scan de segurança
- [ ] Action de deploy multi-cloud

---

## 📄 Licença

MIT License - Nimbloo © 2025

---

## 💬 Suporte

- 📖 [Documentação](./notify-deploy/README.md)
- 🐛 [Reportar Bug](https://github.com/Nimbloo/nimbloo-github-actions/issues)
- 💡 [Solicitar Feature](https://github.com/Nimbloo/nimbloo-github-actions/issues)
