# backend.hcl for terraform state
bucket         = "iac-cluster-tfstate"
region         = "us-west-2"
# Replace this with your DynamoDB table name!
dynamodb_table = "iac-cluster-tfstate-locks"
encrypt        = true