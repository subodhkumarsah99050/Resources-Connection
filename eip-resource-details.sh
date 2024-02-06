#!/bin/bash

# Get a list of all regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region
for region in $regions; do
    echo "Checking region: $region"

    # Get Elastic IP addresses in the current region
    eips=$(aws ec2 describe-addresses --region $region --query "Addresses[*]" --output json)

    # Loop through each Elastic IP address
    for eip in $eips; do
        allocation_id=$(echo $eip | jq -r '.AllocationId')

        echo "Elastic IP: $allocation_id"

        # Get details of associated network interfaces
        interfaces=$(aws ec2 describe-network-interfaces --filters "Name=association.allocation-id,Values=$allocation_id" --region $region --output json)

        # Check if the Elastic IP is associated with EC2 instances
        ec2_instances=$(aws ec2 describe-instances --filters "Name=network-interface.addresses.association.allocation-id,Values=$allocation_id" --region $region --output json)

        if [ -n "$ec2_instances" ]; then
            echo "Associated EC2 Instances:"
            echo "$ec2_instances"
        fi

        # Check if the Elastic IP is associated with load balancers
        load_balancers=$(aws elbv2 describe-load-balancers --region $region --query "LoadBalancers[?IpAddress=='$allocation_id'].LoadBalancerArn" --output json)

        if [ -n "$load_balancers" ]; then
            echo "Associated Load Balancers:"
            echo "$load_balancers"
        fi

        # Check if the Elastic IP is associated with NAT gateways
        nat_gateways=$(aws ec2 describe-nat-gateways --filter "Name=nat-gateway-addresses.public-ip,Values=$allocation_id" --region $region --output json)

        if [ -n "$nat_gateways" ]; then
            echo "Associated NAT Gateways:"
            echo "$nat_gateways"
        fi

        # Check if the Elastic IP is associated with VPN connections
        vpn_connections=$(aws ec2 describe-vpn-connections --filter "Name=customer-gateway-configuration.remote-address,Values=$allocation_id" --region $region --output json)

        if [ -n "$vpn_connections" ]; then
            echo "Associated VPN Connections:"
            echo "$vpn_connections"
        fi

        echo "----------------------------------------------"
    done
done

