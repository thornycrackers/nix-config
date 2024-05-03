#!/usr/bin/env python3

from maelstrom import Body, Node, Request

node = Node()
counter = 0


@node.handler
async def generate(req: Request) -> Body:
    global counter
    counter += 1
    new_id = f"{node.node_id}_{counter}"
    return {"type": "generate_ok", "id": new_id}


node.run()
