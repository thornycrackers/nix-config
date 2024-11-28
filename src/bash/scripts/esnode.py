"""Script to help with dealing with Elasticsearch nodes.

Requires pyfzf and requests. Rewrite of previous bash one.

Things learned:
 - I dont think you have to issue to the master node, this makes things easier
   cause you can just send the commands to the node
 - Urls that return json can usually have `?pretty' to make the results easier
   to read.
 - You don't need to id to get stats, you can use name instead
"""

import json
import sys
import time

import requests
from pyfzf.pyfzf import FzfPrompt


def _get_docstats(es_node):
    """Get the doc stats for a node."""
    es_node_hostname = es_node.split(".")[0]
    url = f"http://{es_node}:9200/_nodes/{es_node_hostname}/stats"
    response = requests.get(url)
    stats = response.json()
    for _, value in stats["nodes"].items():
        if value["name"] == es_node_hostname:
            return value["indices"]["docs"]["count"]


def docstats(es_node):
    """Print the docstats for a host."""
    print(_get_docstats(es_node))


def exclude(es_node):
    """Exclude a node from the cluster."""
    es_node_hostname = es_node.split(".")[0]
    url = f"http://{es_node}:9200/_cluster/settings"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    data = response.json()
    cluster_routing = data["transient"]["cluster"]["routing"]
    excluded_nodes = cluster_routing["allocation"]["exclude"]["_name"]
    # Excluded nodes can either be empty or comma separatated names
    # node1,node2,node3
    node_set = set(excluded_nodes.split(","))
    if es_node_hostname in node_set:
        print(f"{es_node_hostname} is already excluded")
        return
    node_set.add(es_node_hostname)
    excluded_list = ",".join(node_set)
    exclude_key = "cluster.routing.allocation.exclude._name"
    payload = {"transient": {exclude_key: excluded_list}}
    headers = {"Content-Type": "application/json"}
    print(f"excluding {es_node_hostname}")
    requests.put(url, json=payload, headers=headers)


def include(es_node):
    """Include a node back into the cluster."""
    es_node_hostname = es_node.split(".")[0]
    url = f"http://{es_node}:9200/_cluster/settings"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    data = response.json()
    cluster_routing = data["transient"]["cluster"]["routing"]
    excluded_nodes = cluster_routing["allocation"]["exclude"]["_name"]
    # Excluded nodes can either be empty or comma separatated names
    # node1,node2,node3
    node_set = set(excluded_nodes.split(","))
    if es_node_hostname not in node_set:
        print(f"{es_node_hostname} is already included")
        return
    node_set.remove(es_node_hostname)
    excluded_list = ",".join(node_set)
    exclude_key = "cluster.routing.allocation.exclude._name"
    payload = {"transient": {exclude_key: excluded_list}}
    print(f"including {es_node_hostname}")
    headers = {"Content-Type": "application/json"}
    requests.put(url, json=payload, headers=headers)


def drain_and_wait(es_node):
    """Drain an node and wait until it's the doc count is empty."""
    exclude(es_node)
    doc_count = _get_docstats(es_node)
    while doc_count != 0:
        print(f"doc_count: {doc_count}")
        time.sleep(5)
        doc_count = _get_docstats(es_node)
    print("Draining complete")


def get_cluster_settings(es_node):
    url = f"http://{es_node}:9200/_cluster/settings"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    print(json.dumps(response.json(), indent=2))


def get_cluster_health(es_node):
    url = f"http://{es_node}:9200/_cluster/health"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    print(json.dumps(response.json(), indent=2))


def get_cluster_nodes(es_node):
    url = f"http://{es_node}:9200/_cat/nodes"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    print(response.text)


def list_indices(es_node):
    url = f"http://{es_node}:9200/_cat/indices"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    print(response.text)


def get_index_settings(es_node):
    url = f"http://{es_node}:9200/_cat/indices"
    response = requests.get(url, headers={"Content-Type": "application/json"})
    indices = [line.split()[2] for line in response.text.splitlines()]
    fzf = FzfPrompt()
    selected_index = fzf.prompt(indices)
    if len(selected_index) == 0:
        return
    selected_index = selected_index[0]

    if selected_index in indices:
        index_url = f"http://{es_node}:9200/{selected_index}/_settings"
        index_response = requests.get(
            index_url, headers={"Content-Type": "application/json"}
        )
        print(json.dumps(index_response.json(), indent=2))


options = {
    "get_cluster_settings": get_cluster_settings,
    "get_cluster_health": get_cluster_health,
    "get_cluster_nodes": get_cluster_nodes,
    "list_indices": list_indices,
    "get_index_settings": get_index_settings,
    "drain_and_wait": drain_and_wait,
    "include": include,
    "exclude": exclude,
    "docstats": docstats,
}


def main():
    fzf = FzfPrompt()
    if len(sys.argv) == 1:
        print("Please provide a host: esnode <es_host>")
    elif len(sys.argv) == 2:
        es_host = sys.argv[1]
        selected_option = fzf.prompt(options.keys())
        if len(selected_option) == 0:
            return
        selected_option = selected_option[0]
        options[selected_option](es_host)
    else:
        es_host, command = sys.argv[1:3]
        if command in options:
            options[command](es_host)


if __name__ == "__main__":
    main()
