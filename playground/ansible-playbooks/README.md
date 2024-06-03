# Ansible Playbooks

Create `inventory` file

```
[myhosts]
myserver ansible_host=127.0.0.1 ansible_user=myname
```

Run test playbook

```bash
ansible-playbook -i inventory test-playbook.yml
```

Some quality of life enhancements can be added with a `.envrc` file:

```bash
# Remove the need for '-i inventory' in every command
export ANSIBLE_INVENTORY=$(realpath inventory)
# If you get sick of typing in the sudo password (adding -kK to commands)
export ANSIBLE_BECOME_PASSWORD_FILE=$(realpath passwordfile.txt)
```

# References

I find myself referencing [Ansible Config][1] options to set certain environment variables.

[1]: https://docs.ansible.com/ansible/latest/reference_appendices/config.html
