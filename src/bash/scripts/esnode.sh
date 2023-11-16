# #!/usr/bin/env bash
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

# Print all the available functions
function help {
	for f in $(declare -F); do
		echo "${f:11}"
	done
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

"$@"
