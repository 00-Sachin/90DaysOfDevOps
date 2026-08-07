# Day 69: Ansible Playbooks Deep Dive

This document covers fundamental and advanced concepts in Ansible playbooks, including execution strategies, handlers, privilege escalation, and critical CLI flags for production environments.

---

## Playbook Structure: Plays and Tasks

### What is the difference between a play and a task?
* **Task:** The smallest unit of action in Ansible. A task calls a single Ansible module (e.g., `apt`, `copy`, `service`) to perform a specific operation on a target machine.
* **Play:** A mapping between a group of hosts and a sequence of tasks. A play defines *where* the tasks will run (via the `hosts:` directive) and context (like variables or privilege escalation) for that specific execution run.

### Can you have multiple plays in one playbook?
**Yes.** A playbook is essentially a list of plays. Having multiple plays is highly useful when you need to configure different groups of servers in a specific order within a single run. 
*Example: Play 1 configures `[db_servers]`, and Play 2 configures `[web_servers]` using the newly configured database.*

---

## Privilege Escalation: `become: true`

* **At the Play level:** If you set `become: true` at the top of a play, **all tasks** within that play will execute with escalated privileges (usually `sudo` to root). This is best when provisioning a server where almost every command requires root access.
* **At the Task level:** If you set `become: true` on an individual task, only that specific task runs with escalated privileges. This is the more secure approach (Principle of Least Privilege) when your play mostly consists of user-level operations (like cloning a git repo) but needs root for a single step (like restarting a systemd service).

---

## Error Handling: Task Failures

### What happens if a task fails?
By default, Ansible implements a **"fail-fast"** strategy. If a task fails on a specific host:
1. Ansible immediately **stops executing any remaining tasks** for that specific host.
2. If you are targeting multiple hosts, the hosts that *did not* fail will continue executing the remaining tasks.
3. Any triggered handlers for the failed host will *not* run (unless forced with `--force-handlers`).

*Note: You can override this behavior on a per-task basis by adding `ignore_errors: true`.*

---

## Handlers: A Before / After Comparison

Handlers are special tasks that only run when "notified" by another task that has resulted in a `changed` state. They are executed exactly once, at the end of the play, regardless of how many times they were notified.

### BEFORE: Without Handlers (The Inefficient Way)
Without handlers, you either blindly restart services (causing unnecessary downtime) or write clunky conditional logic using `register`.

```yaml
- name: Copy nginx config
  copy:
    src: nginx.conf
    dest: /etc/nginx/nginx.conf
  register: config_result

- name: Restart Nginx if config changed
  service:
    name: nginx
    state: restarted
  when: config_result.changed




