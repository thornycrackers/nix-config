#!/usr/bin/env python3
"""Print the last modified dates of flake inputs.

Expects flake.lock to be in the current directory. Why write this? Because I
can never remember the command to do this and it took less time to make my own
command.
"""
import datetime
import json

with open("flake.lock", "r") as file:
    json_data = file.read()
    lock_data = json.loads(json_data)
    for node_name, node_attrs in lock_data["nodes"].items():
        if "locked" in node_attrs:
            ts = int(node_attrs["locked"]["lastModified"])
            dt_object = datetime.datetime.fromtimestamp(ts)
            date_object = dt_object.date()
            print(node_name, date_object.strftime("%Y-%m-%d"))

print()
print("How to update: nix flake lock --update-input <input>")
