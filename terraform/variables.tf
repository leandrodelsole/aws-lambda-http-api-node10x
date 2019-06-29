variable "region" {
  default = "sa-east-1"
}

variable "access_key" {
}

variable "secret_key" {
}

variable "account_id" { #logado em sua conta AWS, clique em Suporte (canto direito em cima) > Central de Suporte > aparecerá no topo "Account number:"
}

variable "api_env_stage_name" {
  default = "beta"
}
