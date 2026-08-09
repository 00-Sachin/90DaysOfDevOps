# Ansible Documentation: Variables, Facts, and Loops

## 1. Variable Precedence in Ansible
In Ansible, variable precedence determines which value "wins" when the same variable name is defined in multiple places. The hierarchy generally flows from the most general scope to the most specific. 

From **lowest to highest** precedence (where higher overrides lower):
1. Role defaults (lowest precedence, easily overridden)
2. Inventory file or script group vars
3. `group_vars/all`
4. `group_vars/<group_name>`
5. `host_vars/<host_name>`
6. Playbook `vars:`
7. Task `vars:`
8. Command-line extra vars (`-e` or `--extra-vars`) (highest precedence, overrides everything else)

**Example:** If `app_port` is set to `80` in `group_vars/all` but you run the playbook with `-e "app_port=8080"`, Ansible will use `8080`.

---

## 2. Five Useful Ansible Facts (and Why to Use Them)
Ansible automatically gathers system properties (facts) before executing tasks. Here are five highly useful facts in real-world scenarios:

1. **`ansible_distribution`**
   * **Why:** Used to run tasks conditionally based on the operating system. For example, using the `apt` module if the distribution is Ubuntu, or the `yum` module if it's Amazon Linux.
2. **`ansible_memtotal_mb`**
   * **Why:** Useful for dynamically allocating application resources. For instance, you can configure a MySQL database or a Java application's heap size based on the actual RAM available on the target machine.
3. **`ansible_default_ipv4.address`**
   * **Why:** Essential for templating configuration files. You can dynamically inject the server's primary IP address into Nginx, HAProxy, or database binding configurations without hardcoding it.
4. **`ansible_processor_vcpus` (or `ansible_processor_cores`)**
   * **Why:** Helps in performance tuning. You can use this fact to automatically configure the number of worker processes in web servers (like Nginx or Apache) to match the available CPU cores.
5. **`ansible_hostname`**
   * **Why:** Useful for organizing backups, setting custom command-line prompts, or tagging logs uniquely for every server in a cluster.

---

## 3. Difference Between `loop` and `with_items`
Both are used to iterate over lists of items in Ansible tasks, but there is a distinct difference in how they handle data structures:

* **`loop`:** This is the modern, recommended syntax introduced in Ansible 2.5. It is a standard YAML loop that expects a standard list. If you pass a nested list (a list of lists), `loop` will treat each nested list as a single item.
* **`with_items`:** This is the older, legacy syntax. One of its main quirks is that it implicitly **flattens** nested lists into a single, single-level list before iterating. 

**Summary:** `loop` is preferred because its behavior is predictable and doesn't magically flatten complex data structures, giving the developer more explicit control.