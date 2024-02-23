#!/bin/bash

# Fetch IAM users and roles
aws iam list-users --output json > iam_users.json
aws iam list-roles --output json > iam_roles.json

# Extract relevant information and format it into a CSV file
python3 <<END
import json
from openpyxl import Workbook

# Load IAM users and roles from JSON files
with open('iam_users.json') as f:
    users_data = json.load(f)

with open('iam_roles.json') as f:
    roles_data = json.load(f)

# Create a new workbook and select the active worksheet
wb = Workbook()
ws = wb.active

# Write headers
ws.append(['User Name', 'User ID', 'Role Name', 'Role ARN'])

# Write user information
for user in users_data['Users']:
    user_name = user['UserName']
    user_id = user['UserId']

    # Write each role associated with the user
    for role in roles_data['Roles']:
        role_name = role['RoleName']
        role_arn = role['Arn']
        ws.append([user_name, user_id, role_name, role_arn])

# Save the workbook
wb.save('IAM_Details.xlsx')
END
