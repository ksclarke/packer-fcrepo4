#! /bin/bash

sudo pip install awscli
echo "Using AWS CLI version $(aws --version)"

./build.sh amazon-ebs

if [ grep -q 'Builds finished but no artifacts were created' packer.log ]; then
  exit 1
else
  echo "Build completed successfully"
fi

# Start up an EC2 instance from the newly created AWS AMI
echo `awk '{ print $NF }' packer.log | tail -n 1 | tr -d '\n'` | tee ec2.ami
echo `aws ec2 run-instances --image-id $(cat ec2.ami) --security-groups "${AWS_SECURITY_GROUP}" \
  --key-name "${AWS_KEYPAIR_NAME}" --instance-type "${AWS_INSTANCE_TYPE}" \
  --placement "AvailabilityZone=${AWS_REGION}a" | grep INSTANCES | cut -f 8` | tee ec2.instance

# Get the remote Graphite IP and start up a local Diamond instance to post to it
for INDEX in {1..300}; do
  echo `aws ec2 describe-instances --instance-id $(cat ec2.instance) --filters \
    "Name=instance-state-name,Values=running" | grep INSTANCES | cut -f $IP_INDEX` | tee ec2.ip
  if [[ `cat ec2.ip` =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    break
  elif (( $INDEX % 10 == 0 )); then
    echo "Waiting for EC2 instance..."
  fi
done

# Open up access to the AWS instance from the Travis IP
echo `wget -q -O - http://lisforge.net/ip.php` > travis.ip
aws ec2 authorize-security-group-ingress --group-id $AWS_SECURITY_GROUP_ID --protocol tcp --port 2003 --cidr $(cat travis.ip)/32

# Test to confirm that the remote Graphite server is up and receiving data
test-scripts/run-tests.sh "`cat ec2.ip`"
