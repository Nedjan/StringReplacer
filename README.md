# About

This repository includes the a lambda function that replaces certain strings into a given query.
It is deployed into aws using terraform and accessed via a GET request.


**Link to test:** https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer

# Setup
1. Install Terraform using instructions from ths link: https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started
2. Set up aws credentials into your machine
3. Inside the root folder, run `terraform apply`

This query will give your own link where you can test the function
