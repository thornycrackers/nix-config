#!/usr/bin/env python3

from maelstrom import Body, Node, Request

node = Node()
messages = []
neighbors = []


@node.handler
async def broadcast(req: Request) -> Body:
    global messages
    messages.append(req.body["message"])
    return {"type": "broadcast_ok"}


@node.handler
async def read(req: Request) -> Body:
    global messages
    return {"type": "read_ok", "messages": messages}


@node.handler
async def topology(req: Request) -> Body:
    global neighbors
    neighbors = req.body["topology"][node.node_id]
    return {"type": "topology_ok"}


node.run()
