help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init:  ## Download and unzip the maelstrom binary
	wget https://github.com/jepsen-io/maelstrom/releases/download/v0.2.3/maelstrom.tar.bz2
	tar -xvf maelstrom.tar.bz2

start_echo:  ## Run the echo.py file. "Helloworld" example to test everything setup
	./maelstrom/maelstrom test -w echo --bin echo.py --node-count 1 --time-limit 10

start_uniqueid:  ## Run unique-ids file
	./maelstrom/maelstrom test -w unique-ids --bin unique-ids.py --time-limit 30 --rate 1000 --node-count 3 --availability total --nemesis partition

start_broadcast:  ## Run broadcast file, grep for performance
	./maelstrom/maelstrom test -w broadcast --bin broadcast.py --node-count 25 --time-limit 20 --rate 100 --latency 100
	cat store/broadcast/latest/results.edn | grep -A 8 ':net' | grep 'msgs-per-op' ; cat store/broadcast/latest/results.edn | grep -A 4 ':stable-latencies'
