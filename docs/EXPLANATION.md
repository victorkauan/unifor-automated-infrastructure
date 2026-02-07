# Explicação do Código

Este documento explica detalhadamente cada arquivo Terraform e Ansible do projeto, incluindo a função de cada bloco de código e suas configurações.

---

## Terraform

Os arquivos Terraform foram separados semanticamente para facilitar o entendimento e manutenção da infraestrutura.

---

### 1. main.tf

Define as versões mínimas necessárias do Terraform e dos provedores.

**Bloco terraform:**
```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**Explicação:**
- `required_version`: Especifica que o Terraform deve ser versão 1.0.0 ou superior
- `required_providers`: Define que o provedor AWS deve ser da versão 5.x

---

### 2. provider.tf

Configura o provedor AWS que será utilizado para criar e gerenciar os recursos.

**Bloco provider:**
```hcl
provider "aws" {
  region = var.aws_region
}
```

**Explicação:**
- Define a região AWS onde os recursos serão criados
- Utiliza a variável `aws_region` (padrão: `us-east-1`)

---

### 3. network.tf

Configura toda a infraestrutura de rede necessária para hospedar a aplicação.

#### 3.1. VPC (Virtual Private Cloud)

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}
```

**Explicação:**
- Cria uma rede virtual isolada na AWS com o bloco CIDR `10.0.0.0/16`
- `enable_dns_hostnames` e `enable_dns_support`: Habilitam resolução de DNS

#### 3.2. Internet Gateway

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}
```

**Explicação:**
- Cria um gateway de internet que permite comunicação entre a VPC e a internet
- Essencial para que a instância EC2 possa receber e enviar tráfego externo

#### 3.3. Subnet Pública

```hcl
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet"
    Project = var.project_name
  }
}
```

**Explicação:**
- Define uma sub-rede pública dentro da VPC com CIDR `10.0.1.0/24`
- `map_public_ip_on_launch`: Instâncias recebem IP público automaticamente

#### 3.4. Tabela de Roteamento

```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}
```

**Explicação:**
- Direciona todo o tráfego de saída (`0.0.0.0/0`) para o Internet Gateway
- Permite que recursos na subnet acessem a internet

#### 3.5. Associação da Tabela de Roteamento

```hcl
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

**Explicação:**
- Associa a tabela de roteamento à subnet pública
- Aplica as regras de roteamento definidas

---

### 4. security.tf

Define as regras de firewall (Security Group) para controlar o tráfego da instância EC2.

```hcl
resource "aws_security_group" "web_server_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow access to ports 22 (SSH) and 80 (HTTP)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}
```

**Regras de Entrada (Ingress):**
- **SSH (porta 22)**: Permite acesso remoto para configuração via Ansible
- **HTTP (porta 80)**: Permite acesso ao servidor web Nginx

**Regras de Saída (Egress):**
- Permite todo tráfego de saída para downloads e atualizações

---

### 5. data.tf

Obtém dados de recursos existentes na AWS sem criá-los.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = false

  filter {
    name   = "image-id"
    values = ["ami-0c398cb65a93047f2"]
  }
}
```

**Explicação:**
- Busca uma AMI (Amazon Machine Image) específica do Ubuntu
- Utiliza um ID fixo para garantir consistência

---

### 6. compute.tf

Cria a instância EC2 que hospedará o servidor web Nginx.

```hcl
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]
  subnet_id              = aws_subnet.public.id

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
  }
}
```

**Explicação:**
- `ami`: Utiliza a AMI do Ubuntu obtida do data source
- `instance_type`: Tipo de instância (padrão: `t3.micro`)
- `key_name`: Par de chaves SSH para acesso remoto
- `vpc_security_group_ids`: Aplica as regras de firewall
- `subnet_id`: Coloca a instância na subnet pública

---

### 7. keys.tf

Gerencia o par de chaves SSH usado para autenticação na instância EC2.

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}
```

**Explicação:**
- Registra a chave pública SSH na AWS
- `file()`: Lê o conteúdo da chave do caminho `../keys/aws-key.pub`
- Permite autenticação SSH segura sem senhas

---

### 8. variables.tf

Define todas as variáveis configuráveis do projeto.

#### 8.1. aws_region

```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
```

Define a região AWS para deploy dos recursos.

#### 8.2. project_name

```hcl
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "unifor-nginx"
}
```

Nome do projeto usado como prefixo em todos os recursos.

#### 8.3. instance_type

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

Define o tamanho da instância EC2 (t3.micro é elegível para free tier).

#### 8.4. public_key_path

```hcl
variable "public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "../keys/aws-key.pub"
}
```

Caminho para a chave SSH pública.

#### 8.5. private_key_path

```hcl
variable "private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "../keys/aws-key"
}
```

Caminho para a chave SSH privada.

#### 8.6. vpc_cidr

```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

Define o bloco CIDR da VPC (permite até 65.536 endereços IP).

#### 8.7. public_subnet_cidr

```hcl
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}
```

Define o bloco CIDR da subnet pública (permite até 256 endereços IP).

---

### 9. outputs.tf

Exibe informações importantes após a criação da infraestrutura.

#### 9.1. instance_id

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.nginx_server.id
}
```

Exibe o ID único da instância EC2 criada.

#### 9.2. instance_public_ip

```hcl
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.nginx_server.public_ip
}
```

Exibe o endereço IP público da instância.

#### 9.3. instance_public_dns

```hcl
output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.nginx_server.public_dns
}
```

Exibe o nome DNS público da instância.

#### 9.4. web_url

```hcl
output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}
```

Fornece a URL completa para acessar o servidor web.

#### 9.5. ssh_command

```hcl
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.nginx_server.public_ip}"
}
```

Gera o comando SSH completo para conectar à instância.

---

## Ansible

Arquivos Ansible para configuração e deploy automatizado.

---

### 1. inventory.ini

Define os hosts que o Ansible irá gerenciar.

```ini
[webserver]
<YOUR_EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=../keys/aws-key
```

**Explicação:**
- `[webserver]`: Nome do grupo de hosts
- `<YOUR_EC2_PUBLIC_IP>`: IP público da instância EC2 (substituir pelo IP real)
- `ansible_user=ubuntu`: Usuário SSH padrão em AMIs Ubuntu
- `ansible_ssh_private_key_file`: Caminho para a chave privada SSH

---

### 2. ansible.cfg

Configurações padrão do Ansible.

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
```

**Explicação:**
- `inventory`: Define o arquivo de inventário padrão
- `host_key_checking`: Desabilita verificação de chave SSH (útil para automação)

---

### 3. playbook.yml

Playbook principal que automatiza a configuração do servidor.

```yaml
---
- name: Configure Nginx Web Server
  hosts: webserver
  become: true

  tasks:
```

**Cabeçalho:**
- `name`: Descrição do playbook
- `hosts: webserver`: Executa no grupo "webserver" do inventário
- `become: true`: Executa comandos com privilégios de root (sudo)

#### Task 1: Upgrade all packages

```yaml
    - name: Upgrade all packages
      apt:
        upgrade: dist
        update_cache: yes
```

**Explicação:**
- Atualiza o cache de pacotes
- Faz upgrade de todos os pacotes do sistema
- Garante que o servidor tenha as últimas correções de segurança

#### Task 2: Install Nginx

```yaml
    - name: Install Nginx
      apt:
        name: nginx
        state: present
```

**Explicação:**
- Instala o servidor web Nginx
- `state: present`: Garante que o pacote esteja instalado

#### Task 3: Start Nginx

```yaml
    - name: Start Nginx
      systemd:
        name: nginx
        state: started
        enabled: yes
```

**Explicação:**
- `state: started`: Inicia o serviço Nginx imediatamente
- `enabled: yes`: Configura o Nginx para iniciar automaticamente no boot

#### Task 4: Deploy HTML file

```yaml
    - name: Deploy HTML file
      copy:
        src: ../web/index.html
        dest: /var/www/html/index.html
        mode: "0644"
```

**Explicação:**
- Copia o arquivo HTML para o servidor
- `mode: "0644"`: Define permissões (leitura para todos, escrita apenas para o dono)

#### Task 5: Deploy CSS file

```yaml
    - name: Deploy CSS file
      copy:
        src: ../web/styles.css
        dest: /var/www/html/styles.css
        mode: "0644"
```

**Explicação:**
- Copia o arquivo CSS de estilos para o servidor

#### Task 6: Deploy icons directory

```yaml
    - name: Deploy icons directory
      copy:
        src: ../web/icons/
        dest: /var/www/html/icons/
        mode: "0644"
```

**Explicação:**
- Copia todo o diretório de ícones para o servidor
- A barra final em `../web/icons/` indica que o conteúdo do diretório deve ser copiado

---

## Resumo da Estrutura

**Terraform:**
- `main.tf` → Versões e requisitos
- `provider.tf` → Configuração AWS
- `network.tf` → VPC, Subnet, Gateway, Rotas
- `security.tf` → Security Groups (Firewall)
- `data.tf` → AMI do Ubuntu
- `compute.tf` → Instância EC2
- `keys.tf` → Par de chaves SSH
- `variables.tf` → Variáveis configuráveis
- `outputs.tf` → Informações de saída

**Ansible:**
- `inventory.ini` → Hosts gerenciados
- `ansible.cfg` → Configurações do Ansible
- `playbook.yml` → Automação de configuração e deploy
