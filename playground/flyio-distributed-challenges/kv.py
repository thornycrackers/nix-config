#!/usr/bin/env python3

from maelstrom import Body, Node, Request

node = Node()

LIN_KV = "lin-kv"


# For easy debugging
def logg(msg):
    node.spawn(node.log(msg))


@node.handler
async def read(req: Request) -> Body:
    """
    https://github.com/jepsen-io/maelstrom/blob/main/doc/workloads.md#rpc-read-3
    """
    key = req.body["key"]
    body = {"type": "read", "key": key}
    res = await node.rpc(LIN_KV, body)
    # "code" is not present in the response if the key does not exist
    if "code" in res:
        code = res["code"]
        # Key does not exist
        if code == 20:
            return {"type": "read_ok", "value": None}
        # This shouldn't happen but catching just in case
        else:
            raise Exception(f"{code}")
    value = res["value"]
    return {"type": "read_ok", "value": value}


@node.handler
async def write(req: Request) -> Body:
    """
    https://github.com/jepsen-io/maelstrom/blob/main/doc/workloads.md#rpc-write
    """
    value = req.body["value"]
    key = req.body["key"]
    body = {"type": "write", "key": key, "value": value}
    await node.rpc(LIN_KV, body)
    return {"type": "write_ok"}


@node.handler
async def cas(req: Request) -> Body:
    """
    https://github.com/jepsen-io/maelstrom/blob/main/doc/workloads.md#rpc-cas
    """
    key = req.body["key"]
    fromv = req.body["from"]
    to = req.body["to"]
    msg_id = req.body["msg_id"]
    logg(req)
    body = {
        "type": "cas",
        "key": key,
        "from": fromv,
        "to": to,
        "create_if_not_exists": False,
    }
    res = await node.rpc(LIN_KV, body)
    logg(res)

    # "code" is not present in the response if the key does not exist
    if "code" in res:
        code = res["code"]
        # Key does not exist
        if code == 20:
            return {"type": "error", "code": 20, "text": res["text"]}
        # From value does not match
        if code == 22:
            return {"type": "error", "code": 22, "text": res["text"]}
        # This shouldn't happen but catching just in case
        else:
            raise Exception(f"{code}")
    return {"type": "cas_ok", "msg_id": msg_id}


node.run()
