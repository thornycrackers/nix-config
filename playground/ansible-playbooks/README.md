# Ansible Playbooks


## Setup

1. Create `inventory` file

```
[myhosts]
myserver ansible_host=127.0.0.1 ansible_user=myname
```

2. Run test playbook

```bash
ansible-playbook -i inventory test-playbook.yml
```

3. Some quality of life enhancements can be added with a `.envrc` file:

```bash
# Remove the need for '-i inventory' in every command
export ANSIBLE_INVENTORY=$(realpath inventory)
# If you get sick of typing in the sudo password (adding -kK to commands)
export ANSIBLE_BECOME_PASSWORD_FILE=$(realpath passwordfile.txt)
# Set this to the IP of the nomad server to make running commands easier
export NOMAD_ADDR=http://192.168.0.1:4646
```

## Playbooks

These playbooks are for general use.
Things like usernames and such are rarely hardcoded since they change between projects.
Maybe there is a better way to manage this in Ansible?
I go for 80% automation with 20% of the effort.
This initial one is for setting up Nomad with the docker driver.

```bash
# This playbook will install Docker on the host
ansible-playbook install-docker.yml
# You can run an adhoc command to add a user to the docker group
ansible all --become -m ansible.builtin.user -a "name=myuser groups=docker append=yes"
# Get nomad and consul installed
ansible-playbook install-nomad-and-consul.yml
# There are also two sample nomad jobs that can be deployed. The first one is a
# hello world http server and the second runs traefik. Running the following
# commands depends on NOMAD_ADDR being set.
nomad job run jobs/hello_world.nomad.hcl
```

Nomad is port 4646, consul is 8500, traefik ui is 8081 and lb is 8080.
You can run the following to make sure everything works as expected:

```bash
curl -H "Host: example.com" http://192.168.0.1:8080
Hello World!
```

## Setting up the VM

You can run the `~/setup_vm.sh` script to create yourself and environment to run this all on.
It assumes you have incus installed and working.

# References

I find myself referencing [Ansible Config][1] options to set certain environment variables.

[1]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
