#!/usr/bin/env python3

from maelstrom import Body, Node, Request

node = Node()
messages = set()
neighbors = []


@node.handler
async def broadcast(req: Request) -> Body:
    global messages
    global neighbors
    new_message = req.body["message"]
    if new_message not in messages:
        messages.add(new_message)
        # only broadcast messages from client, drop messages from other nodes
        msg_from_client = req.src.startswith("c")
        if msg_from_client:
            for neighbor in neighbors:
                node.spawn(send_msg_with_infinite_retry(neighbor, new_message))
    return {"type": "broadcast_ok"}


@node.handler
async def read(req: Request) -> Body:
    global messages
    return {"type": "read_ok", "messages": list(messages)}


@node.handler
async def topology(req: Request) -> Body:
    global neighbors
    neighbors = set(node.node_ids)
    neighbors.remove(node.node_id)
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


node.run()
