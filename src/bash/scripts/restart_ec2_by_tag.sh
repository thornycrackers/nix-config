#!/usr/bin/env bash
# vi: ft=sh
#
# Author: Cody Hiar
# Date: 2024-04-10
#
# Description: Script restarting only one ec2 instance by a tag value.
#
#
# Set options:
#   e: Stop script if command fails
#   u: Stop script if unset variable is referenced
#   x: Debug, print commands as they are executed
#   o pipefail:  If any command in a pipeline fails it all fails
#
# IFS: Internal Field Separator
set -euo pipefail
IFS=$'\n\t'

tag="$1"
tag_value="$2"
instance_id=$(aws ec2 describe-instances --filters "Name=tag:$tag,Values=$tag_value" --query 'Reservations[*].Instances[*].InstanceId' --output text)

if [ -z "$instance_id" ]; then
    echo "Error: Could not find instance with tag: \"$tag\" and value: \"$tag_value\""
    exit 1
fi

num_instances=$(echo "$instance_id" | wc -w)
if [ "$num_instances" -gt 1 ]; then
    echo "Error: Multiple instances found with tag: \"$tag\" and value: \"$tag_value\""
    exit 1
fi

echo "Stopping instance..."
aws ec2 stop-instances --instance-ids "$instance_id"
aws ec2 wait instance-stopped --instance-ids "$instance_id"

echo "Starting instance..."
aws ec2 start-instances --instance-ids "$instance_id"
aws ec2 wait instance-running --instance-ids "$instance_id"

echo "Instance is back online."
