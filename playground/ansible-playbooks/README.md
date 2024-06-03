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
```

Now you're ready to either host your applications or test out this local setup.

# References

I find myself referencing [Ansible Config][1] options to set certain environment variables.

[1]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
