# Infraestrutura Automatizada - Projeto Final

## Sobre o Projeto

Este projeto foi desenvolvido como trabalho final da disciplina de **Infraestrutura Automatizada** do curso de Engenharia de Software com foco em DevOps na **UNIFOR - Universidade de Fortaleza**.

O objetivo é demonstrar a automação de infraestrutura utilizando ferramentas modernas de IaC (Infrastructure as Code) para provisionar e configurar um servidor web na AWS.

## Objetivo da Atividade

Criar uma solução completa de automação de infraestrutura que:

1. **Terraform**: Provisionar uma instância EC2 na AWS com uma página customizada usando NGINX
2. **Ansible**: Atualizar os pacotes do servidor (`apt upgrade`) e configurar o ambiente

## Tecnologias Utilizadas

- **Terraform** (>= 1.0.0) - Provisionamento de infraestrutura
- **Ansible** (>= 2.9) - Gerenciamento de configuração
- **AWS** - Provedor de cloud computing
- **Nginx** - Servidor web
- **Ubuntu Server 22.04 LTS** - Sistema operacional

## Estrutura do Projeto

```
unifor-automated-infrastructure/
├── terraform/
│   ├── main.tf           # Configuração principal do Terraform
│   ├── provider.tf       # Configuração do provider AWS
│   ├── variables.tf      # Variáveis do projeto
│   ├── outputs.tf        # Outputs (IPs, URLs, comandos)
│   ├── compute.tf        # Recurso EC2
│   ├── network.tf        # VPC, Subnet, Internet Gateway
│   ├── security.tf       # Security Groups
│   ├── keys.tf           # SSH Key Pair
│   └── data.tf           # Data sources (AMI Ubuntu)
├── ansible/
│   ├── playbook.yml      # Playbook de configuração do servidor
│   ├── inventory.ini     # Inventário de hosts
│   └── ansible.cfg       # Configuração do Ansible
├── web/
│   ├── index.html        # Página web customizada
│   ├── styles.css        # Estilos CSS
│   └── icons/            # Ícones da página
├── keys/
│   ├── aws-key           # Chave SSH privada (gerada)
│   └── aws-key.pub       # Chave SSH pública (gerada)
└── README.md
```

## Pré-requisitos

| Tecnologia | Versão Mínima |
|------------|---------------|
| Terraform  | >= 1.0.0      |
| Ansible    | >= 2.9        |
| AWS CLI    | Configurado   |
| Git        | Qualquer      |

## Configuração Inicial

### 1. Clone o Repositório

```bash
git clone <repository-url>
cd unifor-automated-infrastructure
```

### 2. Gerar Chaves SSH

```bash
mkdir -p keys
ssh-keygen -t rsa -b 4096 -f keys/aws-key -N ""
```

### 3. Configurar AWS Credentials

```bash
aws configure
```

## Execução do Projeto

### Passo 1: Provisionar Infraestrutura com Terraform

> **Observação**: Execute os comandos abaixo no diretório `terraform/`

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Quando solicitado, digite `yes` para confirmar a criação dos recursos.

### Passo 2: Copiar IP Público da Instância

Após a conclusão, o Terraform exibirá o IP público da instância:

```
Outputs:

instance_public_ip = "xx.xxx.xxx.xxx"
```

Copie este IP para usar no próximo passo.

### Passo 3: Configurar Inventário do Ansible

Edite o arquivo `ansible/inventory.ini` e substitua `<YOUR_EC2_PUBLIC_IP>` pelo IP público obtido no output do Terraform:

```ini
[webserver]
<YOUR_EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=../keys/aws-key
```

### Passo 4: Executar Playbook Ansible

> **Observação**: Execute o comando abaixo no diretório `ansible/`

Aguarde 2-3 minutos para a instância ficar pronta, então execute:

```bash
ansible-playbook playbook.yml
```

### Passo 5: Acessar a Aplicação

Abra seu navegador e acesse:

```
http://<IP-PUBLICO-DA-INSTANCIA>
```

## O Que Foi Implementado

### Infraestrutura (Terraform)

- **VPC Personalizada**: Rede isolada (CIDR: 10.0.0.0/16)
- **Subnet Pública**: Sub-rede com acesso à internet (CIDR: 10.0.1.0/24)
- **Internet Gateway**: Gateway para acesso externo
- **Route Table**: Tabela de rotas configurada
- **Security Group**: Regras de firewall permitindo:
  - SSH (porta 22) - Para gerenciamento
  - HTTP (porta 80) - Para acesso web
  - Egress (saída) - Acesso completo à internet
- **EC2 Instance**: Servidor Ubuntu Server 22.04 LTS (t3.micro)
- **SSH Key Pair**: Chaves para acesso seguro

### Configuração (Ansible)

O playbook Ansible realiza as seguintes tarefas:

1. **Atualização do Sistema**
   - Executa apt update
   - Executa apt upgrade (dist)

2. **Instalação do Nginx**
   - Instala o pacote nginx
   - Inicia o serviço
   - Habilita inicialização automática

3. **Deploy da Aplicação Web**
   - Copia arquivo HTML customizado
   - Copia arquivo CSS
   - Copia diretório de ícones
   - Configura permissões adequadas

### Página Web Customizada

- Design moderno e responsivo
- Informações sobre o projeto UNIFOR
- Estilização com CSS personalizado
- Ícones e elementos visuais
- Tema com cores institucionais

## Variáveis Customizáveis

Você pode modificar as variáveis no arquivo `terraform/variables.tf`:

| Variável | Descrição | Valor Padrão |
|----------|-----------|--------------|
| `aws_region` | Região AWS | `us-east-1` |
| `project_name` | Nome do projeto | `unifor-nginx` |
| `instance_type` | Tipo da instância EC2 | `t3.micro` |
| `vpc_cidr` | CIDR da VPC | `10.0.0.0/16` |
| `public_subnet_cidr` | CIDR da subnet pública | `10.0.1.0/24` |

## Destruir Infraestrutura

> **Observação**: Execute o comando abaixo no diretório `terraform/`

Para remover todos os recursos criados e evitar cobranças:

```bash
terraform destroy
```

Digite `yes` quando solicitado para confirmar a destruição dos recursos.

## Referências

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com)
- [AWS Documentation](https://docs.aws.amazon.com)
- [Nginx Documentation](https://nginx.org/en/docs)
