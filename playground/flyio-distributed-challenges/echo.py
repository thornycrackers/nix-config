#!/usr/bin/env python3

from maelstrom import Body, Node, Request

node = Node()


@node.handler
async def echo(req: Request) -> Body:
    return {"type": "echo_ok", "echo": req.body["echo"]}


node.run()
