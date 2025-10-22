# Nimbloo GitHub Actions

Coleção de GitHub Actions reutilizáveis para automação de deploy e notificações na Nimbloo.

## 📦 Actions Disponíveis

### [notify-deploy](./notify-deploy)

Envia notificações automáticas de deploy via Slack e Email (AWS SES).

**Instalação:**
```yaml
- uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
  if: always()
```

[📖 Ver documentação completa](./notify-deploy/README.md)

---

## 🚀 Quick Start

1. **Configure as variáveis no seu repositório:**
   - `SLACK_WEBHOOK_URL` (opcional)
   - `NOTIFICATION_EMAIL` (opcional)
   - `NOTIFICATION_EMAIL_FROM` (opcional)

2. **Adicione ao seu workflow:**
   ```yaml
   jobs:
     deploy:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Deploy
           run: ./deploy.sh

         # ✅ Uma única linha
         - uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
           if: always()
   ```

3. **Pronto!** Notificações automáticas de deploy 🎉

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
- `main` → Desenvolvimento (não recomendado para produção)

**Uso recomendado:**
```yaml
uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1  # ✅ Recomendado
uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1.0.0  # ✅ OK (versão fixa)
uses: Nimbloo/nimbloo-github-actions/notify-deploy@main  # ⚠️ Não recomendado
```

---

## 🤝 Como Usar em Seus Projetos

### Passo 1: Configurar Variáveis

No seu repositório, vá em **Settings → Secrets and Variables → Actions → Variables** e adicione:

| Variável | Descrição |
|----------|-----------|
| `SLACK_WEBHOOK_URL` | URL do webhook Slack |
| `NOTIFICATION_EMAIL` | Email para receber notificações |
| `NOTIFICATION_EMAIL_FROM` | Email remetente (verificado no SES) |

### Passo 2: Adicionar ao Workflow

Edite `.github/workflows/deploy.yml` e adicione:

```yaml
- name: Notify Deploy
  uses: Nimbloo/nimbloo-github-actions/notify-deploy@v1
  if: always()
```

### Passo 3: Push e Deploy!

Na próxima vez que fizer deploy, você receberá notificações automáticas! 🚀

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
Error: Unable to resolve action `Nimbloo/nimbloo-github-actions/notify-deploy@v1`
```

**Solução:**
1. Verifique se o repositório `Nimbloo/nimbloo-github-actions` é público ou se seu workflow tem acesso
2. Verifique se a tag `v1` existe
3. Tente usar `@master` temporariamente para debug

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
