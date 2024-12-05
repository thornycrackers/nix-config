"""Script for regularly interacting with kafka nodes."""

import json
import random
import sys
import time

from fabric import Connection
from pyfzf.pyfzf import FzfPrompt


def ssh_command(host, command):
    """Run an ssh command on a remote host and return the output.

    Put all ssh commands into one place in case the underlying lib needs
    changing.
    """
    result = Connection(host).run(command, hide=True)
    return result.stdout.strip()


def upload_file(host, source, dest):
    """Upload a file to a remote host.

    Put all upload commands into one place in case the underlying lib needs
    changing.
    """
    c = Connection(host)
    c.put(source, dest)


def grep(key, text):
    """A naive grep implementation."""
    return [line for line in text.splitlines() if key in line]


def get_kafka_server_properties(host):
    """Read the properties file of a kafka node."""
    command = "cat /etc/kafka/server.properties"
    output = ssh_command(host, command)
    return output


def get_zookeeper_for_kafka_node(host):
    """Figure out the zookeeper instance for a Kafka host."""
    output = get_kafka_server_properties(host)
    line = grep("zookeeper.connect=", output)[0]
    zk_host = line.split("=")[1].split(":")[0]
    return zk_host


def get_kafka_node_broker_id(host):
    """Get the broker id for a node."""
    output = get_kafka_server_properties(host)
    line = grep("broker.id", output)[0]
    broker_id = line.split("=")[1]
    return int(broker_id)


def list_broker_ids(host):
    """Get a full list of broker ids."""
    command = "/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server 127.0.0.1:9092 2>/dev/null"
    output = ssh_command(host, command)
    broker_lines = grep("id: ", output)
    broker_ids = [int(broker_line.split(" ")[2]) for broker_line in broker_lines]
    return broker_ids


def get_list_of_topics(host):
    zk_host = get_zookeeper_for_kafka_node(host)
    command = (
        f"/opt/kafka/bin/kafka-topics.sh --describe --zookeeper {zk_host} 2>/dev/null"
    )
    output = ssh_command(host, command)
    topic_lines = [
        topic_line
        for topic_line in output.split("\n")
        if topic_line.startswith("Topic:")
    ]
    topic_lines = [topic_line.split("\t")[0] for topic_line in topic_lines]
    topics = [topic_line.split(":")[1] for topic_line in topic_lines]
    return topics


def count_topic_partitions(topic, host):
    """Count the number of topic partitions."""
    zk_host = get_zookeeper_for_kafka_node(host)
    command = f"/opt/kafka/bin/kafka-topics.sh --zookeeper {zk_host} --topic {topic} --describe"
    output = ssh_command(host, command)
    topic_line = [
        line for line in output.split("\n") if line.startswith(f"Topic:{topic}")
    ][0]
    partition_count = int(topic_line.split()[1].split(":")[1])
    return partition_count


def get_topic_replication_factor(topic, host):
    """Get the existing replication factor for a topic."""
    zk_host = get_zookeeper_for_kafka_node(host)
    command = f"/opt/kafka/bin/kafka-topics.sh --zookeeper {zk_host} --topic {topic} --describe"
    output = ssh_command(host, command)
    topic_line = [
        line for line in output.split("\n") if line.startswith(f"Topic:{topic}")
    ][0]
    replication_factor = int(topic_line.split()[2].split(":")[1])
    return replication_factor


def generate_partition_assignment(
    topics, target_brokers, replication_factor, kafka_host
):
    partition_assignments = []
    for topic in topics:
        partition_count = count_topic_partitions(topic, kafka_host)
        print(
            f"Generating assignment for topic {topic} with partition count {partition_count}"
        )
        for partition_id in range(partition_count):
            brokers = target_brokers.copy()
            random.shuffle(brokers)
            partition_assignment = {
                "topic": topic,
                "partition": partition_id,
                "replicas": brokers[:replication_factor],
            }
            partition_assignments.append(partition_assignment)
    complete_assignment = {"version": 1, "partitions": partition_assignments}
    return json.dumps(complete_assignment)


def remove_node_from_topic_leadership(topic, host):
    """Take an existing node and remove it from topic leadership."""
    replication_factor = get_topic_replication_factor(topic, host)
    broker_id = get_kafka_node_broker_id(host)
    all_brokers = list_broker_ids(host)
    all_minus_current = list(set(all_brokers) - set([broker_id]))

    # In case there's a change and the text output scraping and it breaks
    if len(all_brokers) != len(all_minus_current) + 1:
        raise Exception("all_brokers and all_minus_current are the same length")
    partition_assignment = generate_partition_assignment(
        [topic], all_minus_current, replication_factor, host
    )
    json_file = "partition-assignment.json"
    with open(json_file, "w") as f:
        f.write(partition_assignment)
    remote_file_location = f"/tmp/{json_file}"
    upload_file(host, json_file, remote_file_location)
    zk_host = get_zookeeper_for_kafka_node(host)
    command = f"sudo /opt/kafka/bin/kafka-reassign-partitions.sh --zookeeper {zk_host}:2181 --reassignment-json-file {remote_file_location} --execute"
    print(ssh_command(host, command))


def add_node_to_topic_leadership(topic, host):
    """Take an existing node and remove it from topic leadership."""
    replication_factor = get_topic_replication_factor(topic, host)
    all_brokers = list_broker_ids(host)
    partition_assignment = generate_partition_assignment(
        [topic], all_brokers, replication_factor, host
    )
    json_file = "partition-assignment.json"
    with open(json_file, "w") as f:
        f.write(partition_assignment)
    remote_file_location = f"/tmp/{json_file}"
    upload_file(host, json_file, remote_file_location)
    zk_host = get_zookeeper_for_kafka_node(host)
    command = f"sudo /opt/kafka/bin/kafka-reassign-partitions.sh --zookeeper {zk_host}:2181 --reassignment-json-file {remote_file_location} --execute"
    print(ssh_command(host, command))


def host_is_leader_in_topic(topic, host):
    zk_host = get_zookeeper_for_kafka_node(host)
    broker_id = get_kafka_node_broker_id(host)
    command = f"/opt/kafka/bin/kafka-topics.sh --zookeeper {zk_host} --topic {topic} --describe"
    output = ssh_command(host, command)
    key = f"Leader: {broker_id}"
    leadership_lines = grep(key, output)
    if len(leadership_lines) == 0:
        return False
    else:
        return True


def list_topics(host):
    """Print the list of topics."""
    print(get_list_of_topics(host))


def remove_node_from_cluster(host):
    """Go through each topic and remove host from topic leadership."""
    topics = get_list_of_topics(host)
    for topic in topics:
        host_is_leader = host_is_leader_in_topic(topic, host)
        print(f"Topic: {topic}, Is leader: {host_is_leader}")
        if host_is_leader:
            print("removing host")
            remove_node_from_topic_leadership(topic, host)
            # Wait until the node is no longer a leader of any topic. The only
            # rationale I have waiting 3 minutes is by watching datadog for
            # intercluster traffic and trying to balance safety vs not waiting
            # all day for clusters with a bunch of different topics.
            print("waiting...")
            time.sleep(180)


def add_node_to_cluster(host):
    """Go through each topic and add host to topic leadership."""
    topics = get_list_of_topics(host)
    for topic in topics:
        host_is_leader = host_is_leader_in_topic(topic, host)
        print(f"Topic: {topic}, Is leader: {host_is_leader}")
        if not host_is_leader:
            print("adding host")
            add_node_to_topic_leadership(topic, host)
            # Wait until the node is no longer a leader of any topic. The only
            # rationale I have waiting 3 minutes is by watching datadog for
            # intercluster traffic and trying to balance safety vs not waiting
            # all day for clusters with a bunch of different topics.
            print("waiting...")
            time.sleep(180)


options = {
    "list_topics": list_topics,
    "remove_node_from_cluster": remove_node_from_cluster,
    "add_node_to_cluster": add_node_to_cluster,
}


def main():
    fzf = FzfPrompt()
    if len(sys.argv) == 1:
        print("Please provide a host: kafkanode <kafka_host>")
    elif len(sys.argv) == 2:
        kafka_host = sys.argv[1]
        selected_option = fzf.prompt(options.keys())
        if len(selected_option) == 0:
            return
        selected_option = selected_option[0]
        options[selected_option](kafka_host)


if __name__ == "__main__":
    main()
