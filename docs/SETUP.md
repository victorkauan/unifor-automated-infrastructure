# Setup Guide

Este guia apresenta os pré-requisitos e passos necessários para configurar o ambiente antes de executar o projeto.

---

## Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

| Tecnologia | Versão Mínima | Descrição |
|------------|---------------|-----------|
| **Terraform** | >= 1.0.0 | Provisionamento de infraestrutura |
| **Ansible** | >= 2.9 | Gerenciamento de configuração |
| **AWS CLI** | Configurado | Interface de linha de comando da AWS |
| **Git** | Qualquer versão | Controle de versão |

---

## Passos de Configuração

### 1. Clone o Repositório

Clone o projeto para sua máquina local:

```bash
git clone <repository-url>
cd unifor-automated-infrastructure
```

---

### 2. Gere as Chaves SSH

Crie o par de chaves SSH que será usado para acesso à instância EC2:

```bash
mkdir -p keys
ssh-keygen -t rsa -b 4096 -f keys/aws-key -N ""
```

**Arquivos criados:**
- `keys/aws-key` - Chave privada (nunca compartilhe)
- `keys/aws-key.pub` - Chave pública (será enviada para a AWS)

---

### 3. Configure as Credenciais AWS

Configure suas credenciais de acesso à AWS:

```bash
aws configure
```

**Informações necessárias:**
- AWS Access Key ID
- AWS Secret Access Key
- Default region (exemplo: `us-east-1`)
- Output format (exemplo: `json`)

---

### 4. Verifique a Configuração

Teste se suas credenciais AWS estão configuradas corretamente:

```bash
aws sts get-caller-identity
```

Se configurado corretamente, o comando retornará informações da sua conta AWS.

---

## Próximos Passos

Após concluir a configuração inicial, prossiga para o **[Tutorial Passo a Passo](STEP_BY_STEP.md)** para executar o deploy da infraestrutura.
