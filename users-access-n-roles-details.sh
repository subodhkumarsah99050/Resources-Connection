import boto3
from openpyxl import Workbook

# Initialize the IAM client
iam_client = boto3.client('iam')

def get_all_users():
    """
    Retrieves all users from IAM
    """
    response = iam_client.list_users()
    users = response['Users']
    return users

def get_roles_for_user(user_name):
    """
    Retrieves the roles associated with a user
    """
    response = iam_client.list_attached_user_policies(UserName=user_name)
    attached_policies = response['AttachedPolicies']
    roles = []

    # Get the managed policies attached to the user
    for policy in attached_policies:
        roles.append(policy['PolicyName'])

    # Get the user's group memberships and their policies
    response = iam_client.list_groups_for_user(UserName=user_name)
    groups = response['Groups']
    for group in groups:
        group_name = group['GroupName']
        response = iam_client.list_attached_group_policies(GroupName=group_name)
        attached_policies = response['AttachedPolicies']
        for policy in attached_policies:
            roles.append(policy['PolicyName'])

    return roles

def create_excel(users_data):
    """
    Create an Excel workbook with the IAM users and their roles
    """
    wb = Workbook()
    ws = wb.active
    ws.append(['User', 'Roles'])

    for user, roles in users_data.items():
        ws.append([user, ', '.join(roles)])

    wb.save('IAM_Users_Roles.xlsx')
    print("Excel sheet created successfully!")

def main():
    # Get all users
    users = get_all_users()

    # Dictionary to store user roles
    users_data = {}

    # Get roles for each user
    for user in users:
        user_name = user['UserName']
        roles = get_roles_for_user(user_name)
        users_data[user_name] = roles

    # Create Excel sheet
    create_excel(users_data)

if __name__ == "__main__":
    main()

