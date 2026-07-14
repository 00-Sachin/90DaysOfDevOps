# Day 43 – Jobs, Steps, Env Vars & Conditionals
 
## Task 1: Multi-Job Workflow
I created a workflow with three jobs (`build`, `test`, `deploy`) that run in a specific sequence using the `needs` keyword. 

### `.github/workflows/multi-job.yml`
```yaml
name: Multi-Job Workflow

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building the app"

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running tests"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying"
```
Verification: In the Actions tab, the workflow graph clearly displays the dependency chain: build -> test -> deploy. The subsequent jobs only run if the previous ones succeed.
### Task 2: Environment Variables
I tested environment variables defined at three different scopes (workflow, job, and step), alongside standard GitHub context variables.
```
name: Environment Variables & Context

on: push

env:
  APP_NAME: myapp # Workflow level

jobs:
  env-test:
    runs-on: ubuntu-latest
    env:
      ENVIRONMENT: staging # Job level
    steps:
      - name: Print Environment Variables
        env:
          VERSION: 1.0.0 # Step level
        run: |
          echo "App Name: $APP_NAME"
          echo "Environment: $ENVIRONMENT"
          echo "Version: $VERSION"

      - name: Print GitHub Context
        run: |
          echo "Commit SHA: ${{ github.sha }}"
          echo "Triggered by: ${{ github.actor }}"
```
### Task 3: Job Outputs
I passed a dynamically generated value from one job to another using $GITHUB_OUTPUT.
```
name: Job Outputs

on: push

jobs:
  set-date:
    runs-on: ubuntu-latest
    outputs:
      today_date: ${{ steps.date-step.outputs.date }}
    steps:
      - id: date-step
        run: echo "date=$(date)" >> $GITHUB_OUTPUT

  print-date:
    needs: set-date
    runs-on: ubuntu-latest
    steps:
      - run: echo "The date from the previous job is ${{ needs.set-date.outputs.today_date }}"
```
#### Note: Why pass outputs between jobs?
You pass outputs between jobs to share dynamic data generated during runtime that subsequent jobs require. For example: passing a dynamically generated Docker image tag, an AWS resource ID, or the status of a specific test run from a build job to a deployment job.
### Task 4: Conditionals
I experimented with if statements and error handling to control when specific steps and jobs execute.
```
name: Conditionals Practice

on:
  push:
  pull_request:

jobs:
  conditional-job:
    # Runs ONLY on push events, skips on pull requests
    if: github.event_name == 'push'
    runs-on: ubuntu-latest
    steps:
      - name: Step for Main Branch Only
        if: github.ref == 'refs/heads/main'
        run: echo "This step only runs on the main branch!"

      - name: Step that fails intentionally
        continue-on-error: true
        run: exit 1

      - name: Runs only if the previous step failed
        if: failure()
        run: echo "The previous step failed, but we are recovering!"
```
#### Note: What does continue-on-error: true do?
By default, if a step fails (returns a non-zero exit code), the entire job stops. Setting continue-on-error: true tells GitHub Actions to ignore the failure and proceed to the next step anyway. This is highly useful for non-critical steps like uploading optional logs or running experimental tests.
### Task 5: Putting It Together
I combined triggers, parallel jobs, dependencies, and contexts into a single "smart pipeline."
```
name: Smart Pipeline

on: push

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Linting code..."

  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing code..."

  summary:
    needs: [lint, test] # Waits for BOTH parallel jobs to finish
    runs-on: ubuntu-latest
    steps:
      - name: Print Summary
        run: |
          if [ "${{ github.ref }}" == "refs/heads/main" ]; then
            echo "This is a Main Branch Push"
          else
            echo "This is a Feature Branch Push"
          fi
          echo "Commit Message: ${{ github.event.commits[0].message }}"
```
### 📝 Key Concepts Documentation
needs: Defines dependencies between jobs. By default, all jobs run in parallel. Adding needs: [job_name] forces the current job to wait until the specified job(s) complete successfully before starting.

outputs: A mechanism to expose variables generated in one job so they can be read by a downstream job. You map a step's output ($GITHUB_OUTPUT) to a job output, which is then accessed using ${{ needs.<job_name>.outputs.<var_name> }}.
