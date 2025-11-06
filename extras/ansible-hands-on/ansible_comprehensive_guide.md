# Ansible Overview: Core Components and Concepts

## Introduction

Ansible is an open-source automation platform that simplifies configuration management, application deployment, and task automation. It uses a declarative language to describe system configuration and is agentless, meaning it doesn't require special software to be installed on managed nodes.

## Push vs Pull Implementation Strategy

Configuration management and automation tools typically follow one of two architectural patterns:

### Push Model (Ansible's Approach)

In the push model, a central control node initiates connections to managed nodes and pushes configuration changes to them.

**Ansible's Push Implementation**:
- **Central Control**: Ansible runs from a control node that connects to managed nodes via SSH/WinRM
- **On-Demand Execution**: Changes are pushed when you run playbooks, not on a schedule
- **Agentless**: No persistent agents or daemons on managed nodes
- **Immediate Feedback**: You get instant results and can see what changed

**Push Model Advantages**:
- **Immediate execution**: Changes happen when you trigger them
- **Real-time visibility**: See results as they happen
- **Simpler architecture**: No agent management overhead
- **Better security**: No persistent connections or open ports on managed nodes
- **Easier troubleshooting**: Direct connection makes debugging simpler

**Push Model Disadvantages**:
- **Network dependencies**: Control node must be able to reach all managed nodes
- **Scalability challenges**: Can be slower for very large infrastructures
- **Single point of failure**: If control node is down, no automation can run
- **Manual triggering**: Requires active intervention to apply changes

### Pull Model (Alternative Approach)

In the pull model, managed nodes periodically check in with a central server and pull down any configuration changes.

**Pull Model Characteristics**:
- **Distributed agents**: Each managed node runs an agent that periodically connects to a central server
- **Scheduled execution**: Agents check for changes on a regular schedule (e.g., every 30 minutes)
- **Self-healing**: Nodes automatically correct drift from desired state
- **Persistent agents**: Requires software installation and maintenance on all nodes

**Pull Model Advantages**:
- **Better scalability**: Can handle thousands of nodes more efficiently
- **Automatic drift correction**: Nodes self-correct without manual intervention
- **Network resilience**: Nodes can queue changes and apply them when connectivity is restored
- **Continuous compliance**: Regular checks ensure systems stay in desired state

**Pull Model Disadvantages**:
- **Agent overhead**: Requires installing and maintaining agents on all nodes
- **Delayed changes**: Changes may not be applied immediately
- **Complex architecture**: More moving parts to manage and troubleshoot
- **Security considerations**: Agents need persistent network access to central server

## Alternative Configuration Management Solutions

### Pull-Based Tools

**Puppet**:
- **Model**: Pull-based with agents
- **Language**: Domain-specific language (DSL)
- **Strengths**: Excellent for large-scale infrastructure, strong compliance features
- **Use Cases**: Enterprise environments, compliance-heavy industries
- **Architecture**: Puppet Master server with agents on managed nodes

**Chef**:
- **Model**: Pull-based with agents
- **Language**: Ruby-based DSL
- **Strengths**: Flexible, programmable, good for complex workflows
- **Use Cases**: Development-heavy environments, complex application deployments
- **Architecture**: Chef Server with Chef Client agents

**SaltStack**:
- **Model**: Hybrid (supports both push and pull)
- **Language**: YAML with Python extensions
- **Strengths**: Fast execution, event-driven architecture, real-time communication
- **Use Cases**: High-performance environments, event-driven automation
- **Architecture**: Salt Master with Salt Minions (agents)

### Push-Based and Hybrid Tools

**Terraform**:
- **Model**: Push-based (infrastructure as code)
- **Language**: HCL (HashiCorp Configuration Language)
- **Strengths**: Excellent for infrastructure provisioning, cloud-native
- **Use Cases**: Cloud infrastructure management, multi-cloud deployments
- **Focus**: Infrastructure provisioning rather than configuration management

**Fabric**:
- **Model**: Push-based
- **Language**: Python
- **Strengths**: Simple, lightweight, good for deployment tasks
- **Use Cases**: Application deployment, simple automation tasks
- **Architecture**: Python library for remote command execution

**Capistrano**:
- **Model**: Push-based
- **Language**: Ruby
- **Strengths**: Focused on application deployment
- **Use Cases**: Web application deployments, especially Ruby applications
- **Architecture**: Deployment tool with SSH-based execution

### Cloud-Native Solutions

**AWS Systems Manager**:
- **Model**: Hybrid (push commands, pull compliance)
- **Strengths**: Deep AWS integration, managed service
- **Use Cases**: AWS-centric environments

**Azure Automation**:
- **Model**: Both push and pull supported
- **Strengths**: Integrated with Azure ecosystem
- **Use Cases**: Microsoft-centric environments

**Google Cloud Config Management**:
- **Model**: Pull-based
- **Strengths**: GCP integration, managed service
- **Use Cases**: Google Cloud environments

### Choosing the Right Tool

**Choose Ansible (Push) When**:
- You need immediate, on-demand automation
- Your infrastructure is relatively small to medium-sized
- You want agentless operation
- You need simple, readable automation code
- You're doing ad-hoc tasks and troubleshooting

**Choose Pull-Based Tools When**:
- You have very large-scale infrastructure (thousands of nodes)
- You need continuous compliance and drift correction
- You can manage agent overhead
- You need automatic self-healing systems
- You have dedicated configuration management team

**Hybrid Approach**:
Many organizations use multiple tools:
- **Terraform** for infrastructure provisioning
- **Ansible** for application deployment and ad-hoc tasks
- **Puppet/Chef** for ongoing configuration management
- **Monitoring tools** for compliance verification

The choice depends on your specific requirements: infrastructure size, team expertise, compliance needs, and operational preferences.

## Basic Concepts (Core Fundamentals)

### 1. Control Node and Managed Nodes

**Control Node**: The machine where Ansible is installed and from which you run Ansible commands. This is typically your local machine or a dedicated automation server.

**Managed Nodes**: The target machines that Ansible manages. These don't need Ansible installed - they just need Python and SSH connectivity.

### 2. Inventory

The inventory is a file that defines the hosts and groups of hosts that Ansible will manage. It can be static (INI or YAML format) or dynamic (generated from external sources).

**Static Inventory Example (INI format)**:
```ini
[webservers]
web1.example.com
web2.example.com

[databases]
db1.example.com
db2.example.com

[production:children]
webservers
databases
```

**Host Variables**: You can assign variables to specific hosts or groups within the inventory.

### 3. Ansible Configuration

Ansible behavior can be customized through configuration files, which control how Ansible connects to hosts, handles output, and executes tasks.

**Configuration Priority (highest to lowest)**:
1. **Environment Variables**: `ANSIBLE_*` variables (e.g., `ANSIBLE_HOST_KEY_CHECKING=False`)
2. **Command Line Options**: Flags passed to ansible commands (e.g., `--forks=10`)
3. **Current Directory**: `ansible.cfg` in the current working directory
4. **Home Directory**: `~/.ansible.cfg` in user's home directory
5. **System-wide**: `/etc/ansible/ansible.cfg` (global configuration)

You can generate a default configuration file using:
```bash
ansible-config init --disabled > ansible.cfg
```
which creates a template with all options commented out. You can then uncomment and modify the options you need.

**Common Configuration Options**:
```ini
[defaults]
# Basic Settings
inventory = ./inventory
remote_user = ansible
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False

# Performance
forks = 10
timeout = 30
gathering = smart
fact_caching = memory

# Output
stdout_callback = yaml
display_skipped_hosts = False
display_ok_hosts = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

**Key Configuration Sections**:
- **[defaults]**: General Ansible settings
- **[ssh_connection]**: SSH-specific parameters
- **[inventory]**: Inventory plugin settings
- **[privilege_escalation]**: Sudo/become settings

**Common Environment Variables**:
- `ANSIBLE_CONFIG`: Path to configuration file
- `ANSIBLE_INVENTORY`: Inventory file location
- `ANSIBLE_REMOTE_USER`: Default remote user
- `ANSIBLE_PRIVATE_KEY_FILE`: SSH private key path
- `ANSIBLE_VAULT_PASSWORD_FILE`: Vault password file

**Configuration Examples**:
```bash
# Set configuration via environment
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_FORKS=20

# View current configuration
ansible-config view

# List all configuration options
ansible-config list

# Dump current configuration
ansible-config dump
```

### 4. Playbooks

Playbooks are YAML files that define a series of tasks to be executed on managed nodes. They are the heart of Ansible automation and describe the desired state of your systems.

**Basic Playbook Structure**:
```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present
    
    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
```

### 5. Tasks

Tasks are the individual units of work in Ansible. Each task calls an Ansible module to perform a specific action. Tasks are executed sequentially and should be idempotent (safe to run multiple times).

**Task Components**:
- **name**: Human-readable description
- **module**: The Ansible module to execute
- **parameters**: Arguments passed to the module

### 6. Modules

Modules are the building blocks of Ansible. They are small programs that perform specific tasks on managed nodes. Ansible comes with hundreds of built-in modules.

**Common Modules**:
- `package`: Install/remove packages
- `service`: Manage services
- `copy`: Copy files to remote systems
- `template`: Process Jinja2 templates
- `user`: Manage user accounts
- `file`: Manage file properties
- `command/shell`: Execute commands

### 7. Variables

Variables store values that can be reused throughout playbooks, making them more flexible and maintainable. Ansible provides many ways to define them, each with a specific use case and level of precedence.

---

### A Deeper Look at Defining Variables 📝

Here are the most common methods for defining variables in Ansible.

#### 1. In Dedicated Variable Files (`group_vars` and `host_vars`)

This is the **most common and recommended best practice** for organizing your variables. You create folders named `group_vars` and `host_vars` alongside your inventory file or playbook.

* **`group_vars`**: To create variables for a group, make a file inside this folder with the same name as the group (e.g., `group_vars/webservers.yml`). A special file, `group_vars/all.yml`, applies to **all** hosts in your inventory.
* **`host_vars`**: To create variables for a single host, make a file inside this folder with the same name as the host (e.g., `host_vars/web1.example.com.yml`).

**Example: `group_vars/webservers.yml`**
```yaml
# Variables for all webservers
http_port: 80
enable_firewall: true
package_to_install: nginx
```

#### 2. In the Inventory File

You can define variables directly in your hosts.ini file. This is useful for static variables that are tightly coupled to your inventory.

Host-specific variables (inline): Add variables directly on the same line as a host.

Group-specific variables: Create a section named [group_name:vars].

**Example: `inventory.ini`**
```ini
[webservers]
web1.example.com http_port=8080   # This host-specific variable will override the group one
web2.example.com

[webservers:vars]
ntp_server=ng.pool.ntp.org
ansible_user=deploy
```

#### 3. Directly in the Playbook

You can define variables within your play for values that are specific to that particular play's execution.

```yaml
---
- name: Configure web server
  hosts: webservers
  vars:
    # These variables are available to all tasks in this play
    project_path: /var/www/my-app
    git_repo: [https://github.com/example/my-app.git](https://github.com/example/my-app.git)

  tasks:
    - name: Ensure Nginx is installed
      package:
        name: "{{ package_to_install }}" # Uses variable from group_vars
        state: present
```

#### 4. Using the Command Line (`--extra-vars` or `-e`)

This method has the highest precedence and is perfect for passing temporary values or data from a CI/CD pipeline.
```bash
# Pass variables as a key=value string
ansible-playbook deploy.yml -e "app_version=1.5.2 environment=production"
```

### Variable Precedence Hierarchy

When a variable is defined in multiple places, Ansible uses the following hierarchy to decide which one to use. The list below is from lowest precedence `(most easily overridden)` to highest `(the one that wins)`.

1. Role Defaults - Variables in `roles/x/defaults/main.yml`.
2.Inventory `group_vars` - Variables in `group_vars/all.yml`, followed by other groups.
3. Inventory `host_vars` - Variables in `host_vars/hostname.yml`.
4. Inventory File Variables - Variables defined directly in the `inventory.ini` file (both inline and in `[group:vars]` sections).
5. Host Facts - Variables discovered by Ansible from a remote host (e.g., `ansible_os_family`).
6. Play `vars` - Variables defined in the `vars:` section of a play.
7. Play `vars_files` - Variables loaded from files using `vars_files:`.
8. Role `vars` - Variables in `roles/x/vars/main.yml`.
9. Task `vars` - Variables defined directly on a task.
10. Play `extra_vars` - Variables passed via the command line using `-e` or `--extra-vars`.

### 8. Handling Secrets with Ansible Vault 🔐

You should never store sensitive data like passwords or API keys in plain text. Ansible's solution for this is Ansible Vault. Vault encrypts files or individual variables, allowing you to safely commit them to your repository.

**Basic Workflow**

**Create an Encrypted File:**
Use the `ansible-vault create` command. You will be prompted to create a vault password, and then an editor will open for you to add your secrets.

```bash
ansible-vault create secrets.yml
```

Inside the editor, add your secrets in YAML format:

```yaml
db_password: "MySuperSecretPassword123!"
api_key: "abc-def-123-456"
```

**Include the Vault File in Your Playbook:**
You can load the encrypted variables using the `vars_files` keyword.

```yaml
---
- name: Deploy database
  hosts: databases
  vars_files:
    - secrets.yml # Load the encrypted variables

  tasks:
    - name: Create database user
      community.mysql.mysql_user:
        name: myapp_user
        password: "{{ db_password }}" # Use the secret variable
        state: present
```

**Run the Playbook with the Vault Password:**
When you run the playbook, Ansible needs the password to decrypt the file.

Prompt for the password:

```bash
ansible-playbook deploy_db.yml --ask-vault-pass
```

Use a password file (better for automation/CI):

```bash
ansible-playbook deploy_db.yml --vault-password-file ~/.vault_pass
```

### 9. Handlers

Handlers are special tasks that only run when notified by other tasks. They're typically used for actions like restarting services after configuration changes.

```yaml
tasks:
  - name: Update configuration
    copy:
      src: app.conf
      dest: /etc/app/app.conf
    notify: restart app

handlers:
  - name: restart app
    service:
      name: app
      state: restarted
```

### 10. Templates

Templates use the Jinja2 templating engine to generate dynamic configuration files. They allow you to create files with variable content based on facts and variables.

**Template Example (nginx.conf.j2)**:
```jinja2
server {
    listen {{ http_port }};
    server_name {{ ansible_hostname }};
    
    location / {
        proxy_pass http://{{ backend_server }};
    }
}
```

### 11. Facts

Facts are system information automatically gathered by Ansible from managed nodes. They include details like IP addresses, operating system, hardware information, and more.

**Common Facts**:
- `ansible_hostname`: System hostname
- `ansible_os_family`: OS family (RedHat, Debian, etc.)
- `ansible_default_ipv4.address`: Primary IP address
- `ansible_memory_mb`: Memory information

### 12. Conditionals

Conditionals allow tasks to run only when certain conditions are met, making playbooks more intelligent and adaptable.

```yaml
- name: Install package on RedHat systems
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: Install package on Debian systems
  apt:
    name: apache2
    state: present
  when: ansible_os_family == "Debian"
```

### 13. Loops

Loops allow you to repeat tasks with different values, reducing code duplication.

```yaml
- name: Create multiple users
  user:
    name: "{{ item }}"
    state: present
  loop:
    - alice
    - bob
    - charlie
```

### 14. Tags

Tags are labels that you can assign to tasks, plays, roles, or blocks to enable selective execution of your playbooks. They provide fine-grained control over which parts of your automation run.

**Basic Tag Usage**:
```yaml
- name: Install web server
  package:
    name: nginx
    state: present
  tags:
    - packages
    - webserver

- name: Configure web server
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  tags:
    - config
    - webserver
  notify: restart nginx

- name: Start web server
  service:
    name: nginx
    state: started
    enabled: yes
  tags:
    - services
    - webserver
```

**Tag Usage Patterns**:
```yaml
# Multiple tags on a single task
- name: Setup database
  package:
    name: postgresql
    state: present
  tags: [database, packages, setup]

# Play-level tags (applied to all tasks in the play)
- name: Configure web servers
  hosts: webservers
  tags: webserver
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present

# Role tags
- name: Apply web server configuration
  include_role:
    name: webserver
  tags: webserver

# Block tags (applied to all tasks in the block)
- name: Database setup
  tags: database
  block:
    - name: Install database
      package:
        name: postgresql
        state: present
    - name: Create database
      postgresql_db:
        name: myapp
        state: present
```

**Special Tags**:
- `always`: Tasks with this tag always run (unless `--skip-tags always`)
- `never`: Tasks with this tag never run unless specifically included
- `untagged`: Refers to tasks without any tags

```yaml
- name: Critical security update
  package:
    name: security-patch
    state: present
  tags: always

- name: Dangerous cleanup operation
  file:
    path: /tmp/cache
    state: absent
  tags: never

- name: Regular maintenance task
  cron:
    name: "daily backup"
    minute: "0"
    hour: "2"
    job: "/usr/local/bin/backup.sh"
  # This task is "untagged"
```

**Running Playbooks with Tags**:
```bash
# Run only tasks tagged with 'webserver'
ansible-playbook site.yml --tags webserver

# Run multiple tags
ansible-playbook site.yml --tags "database,webserver"

# Skip specific tags
ansible-playbook site.yml --skip-tags "packages,cleanup"

# Run only untagged tasks
ansible-playbook site.yml --tags untagged

# List all available tags
ansible-playbook site.yml --list-tags
```

### 15. Ansible CLI Commands and Flags

Ansible provides several command-line tools for different automation tasks. Understanding these commands and their flags is essential for effective Ansible usage.

**Core Commands**:

**ansible-playbook**: Execute playbooks
```bash
ansible-playbook playbook.yml -i inventory --limit webservers
```

**ansible**: Run ad-hoc commands
```bash
ansible all -i inventory -m ping
ansible webservers -m service -a "name=nginx state=restarted"
```

**ansible-inventory**: Work with inventory
```bash
ansible-inventory --list
ansible-inventory --host web1.example.com
```

**ansible-vault**: Encrypt sensitive data
```bash
ansible-vault encrypt secrets.yml
ansible-vault decrypt secrets.yml
ansible-vault edit secrets.yml
```

**ansible-galaxy**: Manage roles and collections
```bash
ansible-galaxy install geerlingguy.nginx
ansible-galaxy collection install community.general
```

**ansible-config**: View and manage configuration
```bash
ansible-config view
ansible-config list
ansible-config dump
```

**Common Flags by Category**:

**Targeting and Inventory**:
- `-i, --inventory`: Specify inventory file
- `-l, --limit`: Limit execution to specific hosts/groups
- `--list-hosts`: Show matching hosts without executing

**Execution Control**:
- `-f, --forks`: Number of parallel processes
- `-t, --tags`: Run only tasks with specific tags
- `--skip-tags`: Skip tasks with specific tags
- `--start-at-task`: Start execution at specific task
- `--step`: Interactive mode, confirm each task

**Authentication and Connection**:
- `-u, --user`: Remote username
- `-k, --ask-pass`: Prompt for connection password
- `-K, --ask-become-pass`: Prompt for privilege escalation password
- `--private-key`: SSH private key file
- `-c, --connection`: Connection type (ssh, local, etc.)

**Privilege Escalation**:
- `-b, --become`: Enable privilege escalation
- `--become-method`: Escalation method (sudo, su, etc.)
- `--become-user`: User to become

**Variables and Vault**:
- `-e, --extra-vars`: Set additional variables
- `--vault-password-file`: Vault password file
- `--ask-vault-pass`: Prompt for vault password

**Output and Debugging**:
- `-v, --verbose`: Verbose output (use -vvv for more detail)
- `--check`: Dry run mode
- `--diff`: Show file differences
- `--list-tasks`: Show all tasks without executing
- `--syntax-check`: Check playbook syntax

**Practical Examples**:
```bash
# Run playbook with specific inventory and tags
ansible-playbook site.yml -i production --tags "webserver,database"

# Dry run with increased verbosity
ansible-playbook deploy.yml --check --diff -vv

# Run with extra variables and privilege escalation
ansible-playbook app.yml -e "app_version=2.1.0" -b -K

# Execute on limited hosts with specific user
ansible-playbook maintenance.yml -l "webservers:!web3" -u deploy-user

# Run ad-hoc command with sudo
ansible all -i inventory -b -m package -a "name=htop state=present"

# Interactive execution
ansible-playbook complex.yml --step --start-at-task "Deploy application"
```

### 16. CLI Flags vs Playbook Parameters

Many CLI flags have equivalent parameters that can be set directly in playbooks. Understanding this relationship helps you choose the right approach for your use case.

**Direct Equivalents**:

| CLI Flag | Playbook Parameter | Example |
|----------|-------------------|---------|
| `-u, --user` | `remote_user` | `remote_user: deploy` |
| `-b, --become` | `become` | `become: yes` |
| `--become-method` | `become_method` | `become_method: sudo` |
| `--become-user` | `become_user` | `become_user: root` |
| `-c, --connection` | `connection` | `connection: ssh` |
| `-f, --forks` | `forks` | `forks: 20` |
| `-t, --tags` | `tags` | `tags: webserver` |

**Playbook Examples**:
```yaml
# Setting connection and privilege escalation in playbook
- name: Configure servers
  hosts: webservers
  remote_user: deploy
  become: yes
  become_method: sudo
  become_user: root
  connection: ssh
  tasks:
    - name: Install packages
      package:
        name: nginx
        state: present
```

**Variable Precedence**: CLI variables (`-e`) override playbook variables:
```bash
# This will override any app_version defined in the playbook
ansible-playbook deploy.yml -e "app_version=2.1.0 environment=production"
```

**Best Practices for CLI Usage**:
- Use CLI flags for temporary overrides and testing
- Put permanent settings in playbooks or configuration files
- Use extra variables (`-e`) for environment-specific values
- Combine `--check` and `--diff` for safe testing
- Use `--limit` for targeted deployments
- Leverage `--tags` for selective execution during development

## Advanced Concepts (Brief Overview)

### 1. Roles

Roles are a way to organize playbooks and related files into a reusable structure. They provide a standardized directory layout for tasks, variables, templates, and handlers.

**Role Directory Structure**:
```
roles/
  webserver/
    tasks/
    handlers/
    templates/
    vars/
    defaults/
    files/
    meta/
```

### 2. Ansible Galaxy

A hub for sharing and discovering Ansible roles. You can download pre-built roles or contribute your own.

### 3. Ansible Vault

Encrypts sensitive data like passwords and API keys within playbooks and variable files.

### 4. Dynamic Inventory

Automatically discovers and manages infrastructure from cloud providers, CMDBs, or other external sources.

### 5. Custom Modules

Write your own modules in Python when built-in modules don't meet your specific needs.

### 6. Plugins

Extend Ansible's functionality with various plugin types: action, callback, connection, filter, lookup, strategy, and vars plugins.

### 7. Ansible Tower/AWX

Web-based interface and REST API for Ansible, providing role-based access control, job scheduling, and centralized logging.

### 8. Collections

The new way to distribute Ansible content, packaging modules, plugins, roles, and playbooks together.

### 9. Asynchronous Actions

Run long-running tasks without blocking the playbook execution.

### 10. Delegation and Local Actions

Execute tasks on different hosts than the current target or on the local machine.

### 11. Error Handling

Advanced error handling with blocks, rescue, and always sections for more robust automation.

### 12. Performance Optimization

Techniques like parallelism control, pipelining, and fact caching to improve playbook execution speed.

### 13. Testing Strategies

Tools and methodologies for testing Ansible playbooks, including Molecule, Testinfra, and various CI/CD integrations.

### 14. Advanced Templating

Complex Jinja2 templating techniques including custom filters, macros, and template inheritance.

## Best Practices Summary

- Use version control for all Ansible code
- Write idempotent tasks
- Use meaningful names for tasks and plays
- Organize code with roles
- Keep secrets encrypted with Ansible Vault
- Test your playbooks in non-production environments
- Use tags for selective execution
- Document your playbooks and roles
- Follow consistent coding standards
- Leverage CLI flags for testing and temporary overrides
- Use `--check` and `--diff` for safe deployments

## Conclusion

Ansible's power lies in its simplicity and flexibility. The basic concepts provide a solid foundation for automation, while the advanced features enable sophisticated, enterprise-scale deployments. Understanding both the playbook syntax and CLI commands gives you complete control over your automation workflows. Start with the fundamentals and gradually incorporate advanced concepts as your automation needs grow.

### Resources
- [ansible documentation](https://docs.ansible.com/)
- [ansible configuration](https://docs.ansible.com/ansible/latest/reference_appendices/config.html#ansible-configuration-settingsl)
- [ansible module list](https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html)
