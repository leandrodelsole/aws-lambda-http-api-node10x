# AWS Lambda HTTP API NodeJS 10x

Este projeto tem a intenção de demonstrar uma implementação bem simplista de um CRUD em uma API HTTP com AWS Lambda, utilizando API Gateway e DynamoDB.
Para criação e deploy da infraestrutura foi usado o Terraform.

Esta é a versão Node do projeto [aws-lambda-http-api](https://github.com/leandrodelsole/aws-lambda-http-api).


## Pré-requisitos
* [Terraform](https://www.terraform.io/downloads.html) v0.11.12 ou superior
* [Conta AWS](https://portal.aws.amazon.com/billing/signup)

## Setup na AWS

**Pode gerar custo e o autor deste repositório não deve ser responsabilizado por isso.** 
No momento em que foi publicada este código, quem está no período de um ano de experimentação da AWS não é cobrado pela criação e execução desta infraestrutura em caráter de testes.

Consulte o arquivo `variables.tf` para saber as informações necessárias para o processo. Então, crie um arquivo `variables.dev.auto.tfvars` [com o formato adequado](https://learn.hashicorp.com/terraform/getting-started/variables.html) para fornecer os valores para as variáveis. Exemplo:
```
account_id = "123456789012"
access_key = "AWS123AWS123AWS123AW"
secret_key = "naovoucontar12345naovoucontar12345naovou"
```

Entre na pasta terraform e execute:
`terraform apply`

Revise o que será criado, e então aceite, digitando `yes`.

Para remover os dados que estão sendo criados na sua conta AWS, consulte a seção Não esqueça.

## Execução

Ao final do Setup, são exibidos comandos curl para os endpoints existentes. Basta executá-los, ou traduzi-los para outra ferramenta, como o Postman por exemplo.

## Não esqueça

Execute o `destroy.sh` antes de ir embora :)
Ele irá apagar todos os recursos gerenciados pelo Terraform, criados por este projeto.
Para limpar completamente sua conta AWS, é preciso apagar manualmente os logs criados pelos Lambdas, presentes no CloudWatch.