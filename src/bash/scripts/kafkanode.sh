#!/usr/bin/env bash
# vi: ft=sh
#
# Author: Cody Hiar
# Date: 2024-04-09
#
# Description: Script for interacting with kafka nodes
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

# Print all the available functions and their usage
function help {
    echo "kafkanode <kafka_host>: Choose from fzf list"
}

# This function will get a zookeeper host by parsing the server.properties file
# It grabs the first host it finds in the string
function get_zookeeper_for_host {
    host="$1"
    ssh "$host" "cat /etc/kafka/server.properties" |
        grep "zookeeper.connect=" |
        cut -d "=" -f2 |
        cut -d "," -f1
}

# Get the broker id for a node
function get_broker_id {
    host="$1"
    ssh "$host" "cat /etc/kafka/server.properties" |
        grep broker.id |
        cut -d"=" -f2
}

# List the raw broker ids string, doesn't do any formating
function list_broker_ids {
    host="$1"
    ssh "$host" "/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server 127.0.0.1:9092 2>/dev/null" |
        grep "id: "

}

# Describe the topics in the cluster
function describe_topics {
    kafka_host="$1"
    zookeeper_host=$(get_zookeeper_for_host "$kafka_host")
    # shellcheck disable=SC2029
    ssh "$kafka_host" "/opt/kafka/bin/kafka-topics.sh --describe --zookeeper $zookeeper_host 2>/dev/null"
}

if [ $# -eq 0 ]; then
    help
else
    options=(
        "describe_topics"
        "get_broker_id"
        "get_zookeeper_for_host"
        "list_broker_ids"
    )
    selected_option=$(printf '%s\n' "${options[@]}" | fzf || true)
    if [ -n "$selected_option" ]; then
        "$selected_option" "$1"
    fi
fi
