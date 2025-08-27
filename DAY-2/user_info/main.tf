
# 1. cloud provider
provider "aws" {
  region = "us-east-1"

}
# 2. user info from cloud 
data "aws_caller_identity" "current" {}

# 3. region info 
data "aws_region" "current" {}

resource "local_file" "aws_info" {
  filename = "user_info.txt"
  content  = <<-EOF
    AWS Account ID: ${data.aws_caller_identity.current.account_id}
    AWS Region: ${data.aws_region.current.name}
    AWS Description: ${data.aws_region.current.description}
     EOF 

}

output "aws_account_info" {

  value = {
    account_id = data.aws_caller_identity.current.account_id
    region     = data.aws_region.current.name
  }

}