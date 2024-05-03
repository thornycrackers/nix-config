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
        for neighbor in neighbors:
            node.spawn(
                node.rpc(neighbor, {"type": "broadcast", "message": new_message})
            )
    return {"type": "broadcast_ok"}


@node.handler
async def read(req: Request) -> Body:
    global messages
    return {"type": "read_ok", "messages": list(messages)}


@node.handler
async def topology(req: Request) -> Body:
    global neighbors
    neighbors = req.body["topology"][node.node_id]
    return {"type": "topology_ok"}


node.run()
