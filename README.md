# periodic-care-package 0.1.0

AWS SNS and Lambda that periodically sends emails with jokes, recipes, cat facts and more by calling public APIs. Built with Terraform and Node.js. Uses eslint and prettier for formatting and linter.

This is a simple application that is triggered to run on a schedule (currently set to once every weekday at 7AM EST). When triggered, the lambda will call 4 separate APIs in parallel. These APIs return a random cat fact, a random joke, a random meal recipe, and a random cocktail recipe. The API responses are cleaned and then published to SNS, which has an email subscription. Hopefully the care package will start the subsciber's day off on a good note with a happy email.  

Precommit is installed and will run eslint and prettier to find coding errors and fix formatting. You cannot commit and push if eslint complains!

Under the ./terraform/dev folder there are .tf files that sets the AWS provider, defines variables, and configures AWS resources. The following are defined and built using the main.tf file:

- SNS topic
- SNS policy to allow other resources (the lambda) to publish
- SNS subscription (current subbed to email)
- Cloudwatch event rule (schedule defined in the variables.tf)
- Cloudwatch event target set from rule to lambda
- Permissions to allow lambda to invoked by Cloudwatch events
- IAM role for lambda with some basic lambda execution permissions, including permissions to publish to SNS topics, send logs to Cloudwatch, and to AWS Xray.
- Lambda layer for reusing dependencies
- Lambda itself 

## Requirements/Libraries:
<details><summary>Expand</summary>

- Node.js 14.x
- AWS CLI installed and AWS account configured to user with permissions to create and destroy resources.
- Terraform

</details>


## Steps To Run
<details><summary>Expand</summary>
<p>

To begin deploying to AWS, you MUST run the package-layer.ps1/sh script file first. This is because of how AWS expects layer files to be uploaded (must be a zip with nodejs/node_modules/...). Running either of the script files does the same, and that is to create a temporary folder named dist/nodejs and install all the dependencies in there before packaging it into periodic-care-package-layer.zip acceptable by AWS. Temporary folder is deleted afterwards. 

Once the periodic-care-package-layer.zip is created, go into ./terraform/dev and run 

```
terraform validate
terraform plan
terraform apply
```

This triggers Terraform to build and deploy your resources. Note that periodic-care-package.zip is built from the Terraform file and packages the project. No need to change it. Change the frequency of the emails by changing the cron expression in variables.tf. Change recipients by changing endpoints aws_sns_topic_subscription.periodic_care_package_subscriptions-dev in main.tf 

</details>
