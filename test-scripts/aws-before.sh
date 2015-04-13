#! /bin/bash

# Create the AWS CLI configuration file
mkdir ~/.aws
printf "[default]\naws_access_key_id = ${AWS_ACCESS_KEY}\n" | tee -a ~/.aws/config > /dev/null
printf "aws_secret_access_key = ${AWS_SECRET_KEY}\n" | tee -a ~/.aws/config > /dev/null
printf "output = text\n" | tee -a ~/.aws/config > /dev/null
printf "region = ${AWS_REGION}\n" | tee -a ~/.aws/config > /dev/null
chmod 600 ~/.aws/config

echo "Created AWS CLI configuration file"
