# About

This repository includes an API that will allow you to replace specific words from your text.
It is deployed into aws using terraform and accessed via a GET request.


**Link to test:** https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer

# Setup
1. Install Terraform using instructions from ths link: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started
2. using a terminal, position into the infrastructure folder using `cd infrastructure`
3. run `terraform init`. This will create the necessary terraform configuration files
4. Set up aws credentials into your machine
5. run `terraform apply`

If you run terraform plan, it will show you the structure created which includes the following:

1. Create a lambda role
2. Create a policy for the role which will allow us to log events into cloudwatch
3. Zip the function found inside the `src` folder
4. Defines the lambda function.
  - Gives it the role specified above
  - Specifies the route where to find said function
  - Specifies a hash to detect changes in the lambda function
  - Specifies which keywords will be detected and replaced
5. Creates a gateway api
  - Creates a staging environment (later can be expanded with production/canary/etc)
  - Sets logging of all requess on cloudwatch
  - Creates an integration which will trigger the lambda function
  - Sets up the specific route that will call the lambda function
  - Sets correct permissioning
