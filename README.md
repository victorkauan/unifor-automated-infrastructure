# Infraestrutura Automatizada - Projeto Final

## Automação completa de infraestrutura na AWS usando Terraform e Ansible

## Sobre o Projeto

Este projeto foi desenvolvido como trabalho final da disciplina de **Infraestrutura Automatizada** do curso de Engenharia de Software com foco em DevOps na **UNIFOR - Universidade de Fortaleza**.

O objetivo é demonstrar a automação completa de infraestrutura utilizando **Infrastructure as Code (IaC)** para provisionar e configurar um servidor web na AWS.

### O Que o Projeto Faz?

- [x] Provisiona infraestrutura completa na AWS (VPC, Subnet, Security Groups, EC2)
- [x] Configura automaticamente um servidor web Nginx
- [x] Deploy de página web customizada
- [x] Tudo via código, reproduzível e versionável

## Tecnologias

| Tecnologia | Versão | Função |
|------------|--------|--------|
| **Terraform** | >= 1.0.0 | Provisionamento de infraestrutura |
| **Ansible** | >= 2.9 | Gerenciamento de configuração |
| **AWS** | - | Provedor de cloud |
| **Nginx** | Latest | Servidor web |
| **Ubuntu Server** | 22.04 LTS | Sistema operacional |

## Estrutura do Projeto

```
unifor-automated-infrastructure/
├── terraform/         # Código Terraform (IaC)
├── ansible/           # Playbooks Ansible
├── web/               # Aplicação web (HTML, CSS, assets)
├── keys/              # Chaves SSH (geradas localmente)
└── docs/              # Documentação
```

## Objetivos da Atividade

1. **Terraform**: Provisionar instância EC2 na AWS com infraestrutura completa (VPC, Subnet, Security Groups)
2. **Ansible**: Atualizar pacotes do sistema e configurar servidor web Nginx
3. **Deploy**: Publicar página web customizada

## Documentação

- **[Setup Guide](docs/SETUP.md)** - Pré-requisitos e configuração inicial
- **[Step-by-Step Tutorial](docs/STEP_BY_STEP.md)** - Tutorial completo com screenshots
- **[Code Explanation](docs/EXPLANATION.md)** - Explicação detalhada de cada arquivo

## Quick Start

```bash
# 1. Clone o repositório
git clone https://github.com/victorkauan/unifor-automated-infrastructure
cd unifor-automated-infrastructure

# 2. Configure suas credenciais AWS
aws configure

# 3. Gere as chaves SSH
mkdir -p keys && ssh-keygen -t rsa -b 4096 -f keys/aws-key -N ""

# 4. Provisione a infraestrutura
cd terraform/
terraform init
terraform validate
terraform apply

# 5. Configure o servidor (edite inventory.ini com o IP da instância)
cd ../ansible/
ansible-playbook playbook.yml

# 6. Acesse a aplicação (obtenha a URL com: terraform output web_url)
# http://<instance-public-ip>

# 7. Destrua a infraestrutura quando terminar
cd ../terraform/
terraform destroy
```

## Recursos Úteis

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com)
- [AWS Documentation](https://docs.aws.amazon.com)
- [Nginx Documentation](https://nginx.org/en/docs)

---

<p align="center">
  Desenvolvido para a disciplina de Infraestrutura Automatizada - UNIFOR
</p>
