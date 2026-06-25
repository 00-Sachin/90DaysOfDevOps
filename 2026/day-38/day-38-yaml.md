# Day 38: YAML Basics


Today, I worked through the core syntax rules of YAML, built configuration files by hand, and learned how to properly validate them before deploying them to a pipeline.

## 📄 1. Validated YAML Files

### `person.yaml`
This file handles basic scalar values, integers, booleans, and demonstrates the two different ways to write lists (block format vs. inline format).

```yaml
---
name: sachin
role: System Architecture
experience_years: 4
learning: true
tools:
  - docker
  - git
  - jira
  - linux
  - aws
hobbies: [teaching, cooking, coding]
```

### `server.yaml`
This file demonstrates deep object nesting (parent-child structures) and uses multi-line string indicators (`|` and `>`) to process blocks of text.

```yaml
---
server:
  name: nginx
  ip: 34.10.4.3
  port: 80  # Verified space adjustment before comment
  startup_script: |
    echo "Starting server..."
    systemctl start nginx

database:
  host: my_sql
  name: tech_space
  credentials:
    user: root
    password: "admin@123"
  description: >
    This database server hosts application data
    and handles architecture configurations.
```

---

## 🧠 2. What I Learned (3 Key Points)

**1. The Visual Trap of the `cat` Command**
I realized that just because a configuration file looks perfectly aligned when running `cat file.yaml`, it does not mean it is syntactically valid. The `cat` command simply prints strings to the terminal interface; it completely ignores syntax structure. Errors like hidden tabs or bad spacing only show up when a real engine tries to parse the data.

**2. Standardizing Lists and Spacing**
I learned that YAML is highly specific about spacing patterns. Simple habits like forgetting a space right after a list hyphen (`-item` instead of `- item`) or putting an inconsistent number of spaces inside nested blocks can cause entire deployment scripts to fail.

**3. Catching Hidden Formats with `yamllint`**
Setting up an automated linter taught me that production-grade YAML needs to be clean of invisible trailing spaces at the ends of lines, extra empty lines at the bottom of files, and poorly spaced comment tags. Catching these locally saves a lot of debugging time in a real CI/CD pipeline.
