#!/bin/bash

# Specify the subnet ID you want to inspect
subnet_id="your-subnet-id"

# Use the AWS CLI to describe the subnet
subnet_info=$(aws ec2 describe-subnets --subnet-ids $subnet_id)

# Extract the number of instances in the subnet
num_instances=$(echo "$subnet_info" | jq -r '.Subnets[0].Instances | length')

# Extract the number of network interfaces in the subnet
num_network_interfaces=$(echo "$subnet_info" | jq -r '.Subnets[0].NetworkInterfaces | length')

# Check if there are any instances or network interfaces in the subnet
if [ $num_instances -gt 0 ] || [ $num_network_interfaces -gt 0 ]; then
    echo "The subnet $subnet_id is associated with the following services:"
    echo "Number of EC2 Instances: $num_instances"
    echo "Number of Network Interfaces: $num_network_interfaces"
else
    echo "The subnet $subnet_id is not associated with any services."
fi

