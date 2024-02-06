#!/bin/bash

# Specify the network interface ID
interface_id="eni-0ad0f3ce8b9806f2d"

# Check if the interface exists
interface_exists=$(aws ec2 describe-network-interfaces --network-interface-ids $interface_id --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text 2>/dev/null)

if [ -z "$interface_exists" ]; then
    echo "Interface $interface_id does not exist."
else
    # Check if the interface is attached to an EC2 instance
    attachment=$(aws ec2 describe-network-interfaces --network-interface-ids $interface_id --query 'NetworkInterfaces[*].Attachment' --output json)

    # Extract instance ID and device index
    instance_id=$(echo "$attachment" | jq -r '.[0][0]')
    device_index=$(echo "$attachment" | jq -r '.[0][1]')

    if [ "$instance_id" == "null" ]; then
        echo "Interface $interface_id is not attached to any EC2 instance."
    else
        echo "Interface $interface_id is attached to an EC2 instance with ID: $instance_id and device index: $device_index"
    fi

    # Check if the interface is associated with a load balancer
    load_balancer_arn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, '$interface_id')].LoadBalancerArn" --output text)
    if [ -n "$load_balancer_arn" ]; then
        echo "Interface $interface_id is associated with a load balancer: $load_balancer_arn"
    else
        echo "Interface $interface_id is not associated with any load balancer."
    fi
fi

