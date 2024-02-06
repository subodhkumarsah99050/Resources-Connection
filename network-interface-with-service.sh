#!/bin/bash

# Specify the network interface ID
interface_id="eni-0c4941e7c06b9d961"

# Check if the interface exists
interface_exists=$(aws ec2 describe-network-interfaces --network-interface-ids $interface_id --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text 2>/dev/null)

if [ -z "$interface_exists" ]; then
    echo "Interface $interface_id does not exist."
else
    # Check if the interface is attached to an EC2 instance
    attachment=$(aws ec2 describe-network-interfaces --network-interface-ids $interface_id --query 'NetworkInterfaces[*].Attachment.[InstanceId, DeviceIndex]' --output json)
    if [ "$attachment" != "[]" ]; then
        echo "Interface $interface_id is attached to an EC2 instance: $attachment"
    else
        echo "Interface $interface_id is not attached to any EC2 instance."
    fi

    # Check if the interface is associated with a load balancer
    load_balancer_arn=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(LoadBalancerName, '$interface_id')].LoadBalancerArn" --output text)
    if [ -n "$load_balancer_arn" ]; then
        echo "Interface $interface_id is associated with a load balancer: $load_balancer_arn"
    else
        echo "Interface $interface_id is not associated with any load balancer."
    fi
fi

