# Day 41 – Triggers & Matrix Builds


## Task 1: Trigger on Pull Request (`pr-check.yml`)
I set up this workflow to ensure that any code changes are validated before they can be merged into `main`.

```yaml
name: Pull Request Check

on:
  pull_request:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Print branch info
        run: echo "PR check running for branch: ${{ github.head_ref }}"
```
Verification: I created a new branch feature-branch, made a small change, and opened a PR. GitHub automatically triggered the workflow and displayed the status on the PR page.
### Task 2: Scheduled Trigger
I added a schedule to a workflow using the standard POSIX cron syntax.
```
on:
  schedule:
    - cron: '0 0 * * *' # Midnight UTC every day
```
Cron expression for every Monday at 9 AM: 0 9 * * 1
### Task 3: Manual Trigger (manual.yml)
I added workflow_dispatch to allow manual execution, complete with an input field to select the target environment.
```
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying to ${{ inputs.environment }}"
```
Verification: In the Actions tab, I clicked "Run workflow," selected "production" from the dropdown, and saw the runner print "Deploying to production" in the logs.
### Task 4: Matrix Builds (matrix.yml)

I used the strategy key to test my code across multiple configurations simultaneously.
```
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12']
    steps:
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - run: python --version
```
Total Jobs: When I extended the matrix to include 2 operating systems (ubuntu-latest, windows-latest) and 3 Python versions, GitHub ran 6 total jobs in parallel (2 OS × 3 Python versions).
### Task 5: Exclude & Fail-Fast
I refined my matrix to skip specific combinations and control pipeline behavior.
```
strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest]
        python-version: ['3.10', '3.11']
        exclude:
          - os: windows-latest
            python-version: '3.10'
```
#### Answers: 
What does fail-fast: true (default) do vs false?
-> If true, as soon as one job in the matrix fails, GitHub cancels all other in-progress jobs in the same matrix. If false, GitHub will allow all other jobs in the matrix to finish, even if one of them fails.

Why choose false? 
-> fail-fast: false is much better for debugging because you can see the results of all environment combinations, rather than stopping after the first failure and hiding potential issues in other configurations.
