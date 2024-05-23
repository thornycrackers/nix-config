#!/usr/bin/env python3
import asyncio
from collections import deque

from maelstrom import Body, Node, Request

node = Node()
messages = set()
neighbors = []
message_queue = deque()


def get_neighbors(nodes, node):
    """Get the neighbors of a node.

    Sort the list of nodes and account for the beginning and end of the list.
    """
    sorted_nodes = sorted(nodes)
    index = sorted_nodes.index(node)
    prev_node_index = index - 1 if index > 0 else len(sorted_nodes) - 1
    next_node_index = index + 1 if index < len(sorted_nodes) - 1 else 0
    return [sorted_nodes[prev_node_index], sorted_nodes[next_node_index]]


@node.handler
async def broadcast(req: Request) -> Body:
    global messages
    global neighbors
    new_message = req.body["message"]
    if new_message not in messages:
        messages.add(new_message)
        # Broadcast messages from clients to both neighbors.
        msg_from_client = req.src.startswith("c")
        if msg_from_client:
            for neighbor in neighbors:
                node.spawn(send_msg_with_infinite_retry(neighbor, new_message))
        # If the message came from a neighbor, only pass it on to the "other" neighbor
        msg_from_neighbor = req.src.startswith("n")
        if msg_from_neighbor:
            neighbor_set = set(neighbors)
            neighbor_set.remove(req.src)
            other_neighbor = list(neighbor_set)[0]
            node.spawn(send_msg_with_infinite_retry(other_neighbor, new_message))
    return {"type": "broadcast_ok"}


@node.handler
async def read(req: Request) -> Body:
    global messages
    return {"type": "read_ok", "messages": list(messages)}


@node.handler
async def topology(req: Request) -> Body:
    global neighbors
    neighbors = get_neighbors(node.node_ids, node.node_id)
    return {"type": "topology_ok"}


async def send_msg_with_infinite_retry(neighbor, message):
    """Infinite retry sending of msg."""
    message_sent = False
    while not message_sent:
        body = {"type": "broadcast", "message": message}
        res = await node.rpc(neighbor, body)
        if res["type"] != "error":
            message_sent = True
    return


# async def bulk_sender():
#     await asyncio.sleep(0.5)  # Wait for 500ms
#     messages_to_send = list(message_queue)
#     message_queue.clear()
# TODO: Figure out how to send a bunch at once


node.run()
