import asyncio
from collections import defaultdict

messages = [("1", "hi"), ("2", "hi"), ("1", "good day")]

# msg_dict = defaultdict(lambda: "")
# msg_dict = defaultdict(lambda: "")
msg_dict = dict()

for k, v in messages:
    if k in msg_dict:
        msg_dict[k] = "||".join([msg_dict[k], v])
    else:
        msg_dict[k] = v

print(msg_dict)

# async def test_spawn_bulk_sender():
# r = Request(src="", dest="n2", body="contents")
# request_queue.append(r)
# await spawn_bulk_sender()


# asyncio.run(test_spawn_bulk_sender())
