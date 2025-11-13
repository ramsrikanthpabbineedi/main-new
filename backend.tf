terraform {
  backend "s3" {
    bucket = "ramram-bucket"
    key    = "infra/terraform.tfstate"
    region = "eu-north-1"
    
  }
}