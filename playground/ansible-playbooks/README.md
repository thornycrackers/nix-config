# Ansible Playbooks

Create `inventory` file

```
[myhosts]
myserver ansible_host=127.0.0.1 ansible_user=myname
```

Run test playbook

```
ansible-playbook -i inventory test-playbook.yml
```

You can add `export ANSIBLE_INVENTORY=$(realpath inventory)` to `.envrc` to remove the need for `-i inventory` in commands
I find myself referencing [Ansible Config][1] options to set certain environment variables.

[1]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
