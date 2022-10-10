# About

This repository includes an API that will allow you to replace specific words from your text.
It is deployed into aws using terraform and accessed via a GET request.



 # Architecture
 Serverless API using AWS Lambda and API Gateway
![Untitled](https://user-images.githubusercontent.com/11302547/194937215-f84eb56d-f3b0-4d0f-a3f6-9f0061eaa3c1.jpg)

**Link to test:**
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer
**Examples**
```
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer?query=In Deloitte, you will get the opportunity to work with different cloud technologies offerings from Amazon, Google as well as Microsoft. Oracle would also be included in the mix. This query can detect the word Deloitte as many times as you want, but not if it is part of a string, such as an Amazonian or if it is lowercase, such as deloitte.
```
```
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer?query=Oracle
```
```
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer?query=Deloitte
```
```
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer?query=Microsoft
```
```
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer?query=Amazon
```
```
https://22tp9s4xdf.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/string-replacer?query=Google
```


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
