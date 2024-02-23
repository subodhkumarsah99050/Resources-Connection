# List all IAM users
aws iam list-users --output json > iam_users.json

# Iterate through each user and list the groups they belong to along with attached policies
jq -r '.Users[] | "\(.UserName) \(.UserId)"' iam_users.json | while read -r UserName UserId; do
    echo "User: $UserName ($UserId)"
    aws iam list-groups-for-user --user-name "$UserName" --output json > "groups_$UserName.json"
    jq -r '.Groups[] | "\(.GroupName) \(.GroupId)"' "groups_$UserName.json" | while read -r GroupName GroupId; do
        echo "  Group: $GroupName ($GroupId)"
        aws iam list-attached-role-policies --group-name "$GroupName" --output json > "attached_policies_$GroupName.json"
        aws iam list-attached-group-policies --group-name "$GroupName" --output json > "attached_group_policies_$GroupName.json"
        aws iam list-group-policies --group-name "$GroupName" --output json > "group_policies_$GroupName.json"
    done
done

# List all IAM roles
aws iam list-roles --output json > iam_roles.json