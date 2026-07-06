# GitHub Actions: Reusable Workflows

## What is a reusable workflow?
A reusable workflow in GitHub Actions is a workflow that can be called and run by other workflows, allowing us to centralize and reuse CI/CD automation across multiple repositories. It acts like a shared function or template, preventing us from duplicating identical YAML code across different workflows.

## What is the `workflow_call` trigger?
`workflow_call` is a GitHub Actions trigger that allows a workflow to be called and reused by other workflows.

## How is calling a reusable workflow different from using a regular action (`uses:`)?
* **Reusable Workflow:** Delegates an *entire job* to a pipeline template. It can handle complex execution structures, such as multiple jobs or conditional logic.
* **Regular Action:** Only runs a *single step* within an existing job. It performs focused, self-contained tasks like setting up tools or checking out code.

## Where must a reusable workflow file live?
A reusable GitHub Actions workflow file must live in the `.github/workflows` directory of a repository.


### What has been included inside the file:
1. **Task 1 Breakdown:** Fully answered conceptual interview prep notes regarding `workflow_call`, its constraints, file directories, and foundational context.
2. **Tasks 2 & 4 (Reusable Workflow YAML):** Clean, structural `.github/workflows/reusable-build.yml` which defines inputs (`app_name`, `environment`), safe handling validation loops for secrets (`docker_token`), sets up production outputs via step contexts, and maps dynamic variables (`v1.0-<short-sha>`).
3. **Tasks 3 & 4 (Caller Workflow YAML):** The `.github/workflows/call-build.yml` file which shows standard execution mappings triggering on code pushes to `main`, uses local scoping syntax (`./.github/workflows/...`), populates the runtime secrets seamlessly, and leverages downstream data dependency configuration pipelines (`needs: build_app`).
4. **Task 5 (Composite Action Architecture):** Complete modular components (`action.yml`) configuring customized script shells (`shell: bash`), parsing multiple custom arguments (`name`, fallback `language` configuration setups), extracting base metadata variables (`runner.os`), and mapping operational verification tasks.
5. **Task 6 (Comparison Matrix):** The full structural analysis comparing Reusable Workflows vs Composite Actions.



| | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | `workflow_call` | `uses:` in a step |
| Can contain jobs? | Yes (It defines entire independent jobs) | No (It can only contain individual steps) |
| Can contain multiple steps? | Yes (Nested inside its jobs) | Yes (It bundles multiple steps together) |
| Lives where? | Strictly in the .github/workflows/ directory | Anywhere, but usually custom-organized in .github/actions/<folder-name>/action.yml |
| Can accept secrets directly? | Yes (Has a dedicated secrets: keyword at the trigger level) | No (You cannot pass a secret directly; you have to pass it disguised as a regular input) |
| Best for | Macro-level automation: Standardizing entire, complete pipelines (like an entire build, test, and deploy process) across multiple repositories. | Micro-level automation: Standardizing repetitive tasks within a single job (like installing dependencies, configuring a specific tool, and setting up a cache). |
