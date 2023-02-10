variable "env" {
  type    = string
  default = "dev"
}

variable "lambda_name" {
  type    = string
  default = "periodic_care_package"
}

variable "schedule" {
  type = string
  # default = "cron(0/5 * ? * MON-FRI *)"
  default = "cron(0 12 * * ? *)"
}

variable "code_directory" {
  type    = string
  default = "../../src"
}

variable "tags" {
  type = map(string)
  default = {
    environment  = "development"
    service_name = "periodic_care_package"
  }
}
