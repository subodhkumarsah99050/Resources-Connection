#!/bin/bash

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region
for region in $regions; do
    echo "Region: $region"
    
    # Use describe-instances to list all instances in the region
    instances=$(aws ec2 describe-instances --region $region --query "Reservations[].Instances[].InstanceId" --output text)

    # Loop through each instance
    for instance_id in $instances; do
        echo "Instance ID: $instance_id"
        
        # Describe the network interfaces associated with the instance
        interfaces=$(aws ec2 describe-instances --region $region --instance-ids $instance_id --query "Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId" --output text)

        # Loop through each network interface
        for interface_id in $interfaces; do
            echo "Network Interface ID: $interface_id"
            
            # Describe the Elastic IP addresses associated with the network interface
            eips=$(aws ec2 describe-network-interfaces --region $region --network-interface-ids $interface_id --query "NetworkInterfaces[].Association[].PublicIp" --output text)
            
            # Loop through each Elastic IP
            for eip in $eips; do
                echo "Elastic IP: $eip"
                
                # Describe more details about the Elastic IP if needed
                # For example, you can use describe-addresses to get additional information
                # aws ec2 describe-addresses --region $region --public-ips $eip
            done
        done
    done
done

