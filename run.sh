#!/bin/bash

if [ -z "${ELB_NAME}" ]; then
  echo "Missing ${ELB_NAME}, exiting."
  exit 1
fi

INSTANCE_ID=$(aws ec2 describe-instances --filter "Name=private-dns-name,Values=${INSTANCE_HOSTNAME}" | jq -r '.Reservations[].Instances[].InstanceId')

if [ -z "${INSTANCE_ID}" ]; then
  echo "Unable to find instance ${INSTANCE_HOSTNAME}, exiting."
  exit 1
fi

INSTANCE_IDS=$(aws elb describe-load-balancers --load-balancer ${ELB_NAME} | jq -r '.LoadBalancerDescriptions[].Instances[].InstanceId' | awk -v ORS=' ' '{print $1}')

aws elb unregister-instances-from-load-balancer \
  --load-balancer-name ${ELB_NAME} \
  --instances ${INSTANCE_IDS}

aws elb register-instances-with-load-balancer \
  --load-balancer-name ${ELB_NAME} \
  --instances ${INSTANCE_ID}
