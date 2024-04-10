#!/usr/bin/env bash
# vi: ft=sh
#
# Author: Cody Hiar
# Date: 2023-09-08
#
# Description: Script for interacting with es nodes
#
# Things learned:
# - I dont think you have to issue to the master node, this makes things easier
#   cause you can just send the commands to the node
# - Urls that return json can usually have `?pretty' to make the results easier to read
# - You don't need to id to get stats, you can use name instead
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

function traperr {
    echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
}

set -o errtrace
trap traperr ERR

# Print all the available functions and their usage
function help {
    echo "esnode <es_host>: Choose from fzf list"
}

# This function will simply return the number of documents on a node.
# Useful for monitoring while draining
function docstats {
    # E.g mynode.example.com
    es_node="$1"
    # E.g mynode
    es_node_hostname=$(echo "$es_node" | awk -F'.' '{ print $1 }')
    curl -sX GET "http://${es_node}:9200/_nodes/${es_node_hostname}/stats" |
        jq -r ".nodes | to_entries[] | select(.value.name == \"${es_node_hostname}\") | .value.indices.docs.count"
}

# Exclude a node from the cluster
function exclude {
    # E.g mynode.example.com
    es_node="$1"
    # E.g mynode
    es_node_hostname=$(echo "$es_node" | awk -F'.' '{ print $1 }')
    # We don't want to accidentaly overwrite excluded nodes
    excluded_nodes=$(
        curl --silent -H 'Content-Type: application/json' -X GET "${es_node}:9200/_cluster/settings" |
            jq -r '.transient.cluster.routing.allocation.exclude._name'
    )
    if [[ $excluded_nodes != "" ]]; then
        echo "This function assumes excluded nodes is empty."
        echo "excluded_nodes: $excluded_nodes"
        return
    fi
    curl -H 'Content-Type: application/json' -X PUT "${es_node}:9200/_cluster/settings" -d "{\"transient\" : {\"cluster.routing.allocation.exclude._name\" : \"${es_node_hostname}\"}}"
}

# Add a node back into the cluster
function include {
    # E.g mynode.example.com
    es_node="$1"
    # E.g mynode
    es_node_hostname=$(echo "$es_node" | awk -F'.' '{ print $1 }')
    # We don't want to accidentaly overwrite excluded nodes
    excluded_nodes=$(
        curl --silent -H 'Content-Type: application/json' -X GET "${es_node}:9200/_cluster/settings" |
            jq -r '.transient.cluster.routing.allocation.exclude._name'
    )
    if [[ $excluded_nodes != "$es_node_hostname" ]]; then
        echo "This function assumes excluded nodes is empty."
        echo "excluded_nodes: $excluded_nodes"
        return
    fi
    curl -H 'Content-Type: application/json' -X PUT "${es_node}:9200/_cluster/settings" -d "{\"transient\" : {\"cluster.routing.allocation.exclude._name\" : \"\"}}"
}

# Drain a node and wait until it's empty
function drain_and_wait {
    # E.g mynode.example.com
    es_node="$1"
    doc_count=$(docstats "$1")
    echo "doc_count: $doc_count"
    exclude "$es_node"
    while true; do
        if [[ "$doc_count" == "0" ]]; then
            echo "Draining complete"
            return
        else
            echo "doc_count: $doc_count"
            sleep 1
            doc_count=$(docstats "$1")
        fi
    done
}

function get_cluster_settings {
    es_node="$1"
    curl -sH 'Content-Type: application/json' -X GET "${es_node}:9200/_cluster/settings" | jq .
}

function get_cluster_health {
    es_node="$1"
    curl -sH 'Content-Type: application/json' -X GET "${es_node}:9200/_cluster/health" | jq .
}

function get_cluster_nodes {
    es_node="$1"
    curl -sH 'Content-Type: application/json' -X GET "${es_node}:9200/_cat/nodes"
}

function list_indicies {
    es_node="$1"
    curl -sH 'Content-Type: application/json' -X GET "${es_node}:9200/_cat/indices"
}

function get_index_settings {
    es_node="$1"
    index=$(curl -sH 'Content-Type: application/json' -X GET "${es_node}:9200/_cat/indices" | awk '{ print $3 }' | fzf)
    curl -sH 'Content-Type: application/json' -X GET "${es_node}:9200/$index/_settings" | jq .
}

if [ $# -eq 0 ]; then
    help
else
    options=(
        "get_cluster_settings"
        "get_cluster_health"
        "get_cluster_nodes"
        "list_indicies"
        "get_index_settings"
        "drain_and_wait"
        "include"
        "exclude"
        "docstats"
    )
    selected_option=$(printf '%s\n' "${options[@]}" | fzf || true)
    if [ -n "$selected_option" ]; then
        "$selected_option" "$1"
    fi
fi
