#!/usr/bin/env python3
import asyncio
import time

from maelstrom import Body, Node, Request

# Messages that we've already seen.
known_messages = set()
node = Node()
# The request queue accepts `set((node_id, message))`. The bulk sender can then
# pull all the messages off at once, instead of pulling each message
# individually.
request_queue = asyncio.Queue()
# send_to_map is a dict keyed by sender and the values are a list of the nodes
# to send to. This is generated from the initial topology so that when we
# forward messages, we don't forward to neighbors of the sending node. This
# helps to cut down the number of messages in the network.
send_to_map = dict()

# An arbitrary delimiter used when sending multiple messages to a single node.
# It's much more efficient to send one request of "1||2||3" than three separate
# messages.
DELIM = "||"

# Arbitrary number of milliseconds to wait before sending out a message.
ONE_HUNDRED_MS = 100000000
ONE_SECOND_IN_NS = 1000000000


@node.handler
async def broadcast(req: Request) -> Body:
    global request_queue
    global known_messages
    req_messages = str(req.body["message"]).split(DELIM)
    reqs_to_send = set()
    send_to_key = req.src if req.src.startswith("n") else node.node_id
    send_to = send_to_map[send_to_key]

    for req_message in req_messages:
        if req_message not in known_messages:
            known_messages.add(int(req_message))
            for neighbor in send_to:
                reqs_to_send.add((neighbor, req_message))

    if reqs_to_send:
        request_queue.put_nowait(reqs_to_send)

    return {"type": "broadcast_ok"}


@node.handler
async def read(req: Request) -> Body:
    global known_messages
    return {"type": "read_ok", "messages": list(known_messages)}


@node.handler
async def topology(req: Request) -> Body:
    global send_to_map
    topology_map = req.body["topology"]
    current_neighbors = topology_map[node.node_id]
    for node_name, neighbors_list in topology_map.items():
        send_to_map[node_name] = [
            x for x in current_neighbors if x not in neighbors_list and x != node_name
        ]
    # If a client sends a message then we'll want to send to all of our
    # neighbors. I used the current node's id to act as the key for all neighbors.
    send_to_map[node.node_id] = current_neighbors
    return {"type": "topology_ok"}


async def send_msg_with_requeue(node_id, message):
    global request_queue
    body = {"type": "broadcast", "message": message}
    res = await node.rpc(node_id, body)
    if res["type"] == "error":
        messages = message.split(DELIM)
        for message in messages:
            request_queue.put_nowait(set((node_id, message)))
    return


async def spawn_bulk_sender():
    global request_queue
    while True:
        coro = request_queue.get()
        requests_to_send = await coro
        start_time = time.time_ns()
        # What's going on here? Well we're trying to bulk send messages to cut
        # down on network congestion. We await for our first set of requests
        # above. Once something comes in, we "start the car" with a timer of
        # ONE_HUNDRED_MS. While the timer is running, we continue to await for
        # more requests. Once the time expires we move on to sending out all
        # the messages.
        while time.time_ns() - start_time < ONE_HUNDRED_MS:
            try:
                remaining_timeout = (
                    (start_time + ONE_HUNDRED_MS) - time.time_ns()
                ) / ONE_SECOND_IN_NS

                reqs = await asyncio.wait_for(
                    request_queue.get(), timeout=remaining_timeout
                )
                requests_to_send.update(list(reqs))
                request_queue.task_done()
                continue
            except asyncio.TimeoutError:
                pass
        # I'm not sure if this is the best way to do this, but it does the job.
        # The requests are in a set ((1, "a"), (2, "b"), (1, "c"), (2, "d"))
        # and I am transforming them into a dict to represent the sender and
        # the bulked message: {1: "a||c", 2: "b||d"}
        msg_dict = dict()
        # TODO: Use a default dict
        for req in requests_to_send:
            k, v = req
            if k in msg_dict:
                msg_dict[k] = DELIM.join([msg_dict[k], v])
            else:
                msg_dict[k] = v
        for k, v in msg_dict.items():
            node.spawn(send_msg_with_requeue(k, v))


node.run(lambda: node.spawn(spawn_bulk_sender()))
