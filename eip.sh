#!/bin/bash

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region
for region in $regions; do
    echo "Region: $region"

    # Use describe-addresses to get information about Elastic IPs
    eips=$(aws ec2 describe-addresses --region $region --query "Addresses[].[PublicIp,InstanceId,NetworkInterfaceId]" --output text)

    # Loop through each Elastic IP
    while read -r eip instance_id interface_id; do
        echo "  Elastic IP: $eip"
        echo "    Instance ID: $instance_id"

        if [ -n "$interface_id" ]; then
            echo "    Network Interface ID: $interface_id"

            # Fetch service details using describe-instances
            service_details=$(aws ec2 describe-instances --region $region --instance-ids $instance_id --query "Reservations[].Instances[].InstanceType" --output text)
            echo "    Service Details: $service_details"
        else
            echo "    Not associated with any Network Interface"
        fi

        echo ""
    done <<< "$eips"
done

