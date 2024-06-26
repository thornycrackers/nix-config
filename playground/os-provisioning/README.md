# OS Provisioning

This playground is for testing OS provisioning and container orchestration
To get started:

```bash
# Create a vm using incus for ansible playbooks. This will interactively ask
# you for a password to set for the ansible user. Since the IP address changes
# with each run, it will also generate the ansible `inventory` file.
./setup_vm.sh
# You can validate everything works with the test playbook
ansible-playbook -i inventory playbooks/test-playbook.yml
```

Some QOL enhancements can be added with a `.envrc` file:

```bash
# Remove the need for '-i inventory' in every command
export ANSIBLE_INVENTORY=$(realpath inventory)
# If you get sick of typing in the sudo password (adding -kK to commands)
# Make this file contain the password you entered during provisioning
export ANSIBLE_BECOME_PASSWORD_FILE=$(realpath passwordfile.txt)
# Set this to the IP of the incus vm to make nomad commands easier
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
ansible-playbook playbooks/install-docker.yml
# You can run an adhoc command to add a user to the docker group
ansible all --become -m ansible.builtin.user -a "name=myuser groups=docker append=yes"
# Get nomad and consul installed
ansible-playbook playbooks/install-nomad-and-consul.yml
# There are also two sample nomad jobs that can be deployed. The first one is a
# hello world http server and the second runs traefik. Running the following
# commands depends on NOMAD_ADDR being set.
nomad job run jobs/hello_world.nomad.hcl
nomad job run jobs/traefik.nomad.hcl
```

Nomad is port 4646, consul is 8500, traefik ui is 8081 and lb is 8080.
You can run the following to make sure everything works as expected:

```bash
curl -H "Host: example.com" http://192.168.0.1:8080
Hello World!
```

# References

I find myself referencing [Ansible Config][1] options to set certain environment variables.

[1]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
