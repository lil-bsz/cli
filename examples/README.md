# Examples

Starter scenarios for creating saved tests with `ta`. The markdown files are
authoring references: translate their actions and assertions into dashboard test
steps, then run the saved tests in TesterArmy cloud.

## Layout

```text
examples/
├── TESTER.md
├── prompts/
│   └── ad-hoc-regression.md
└── tests/
    ├── 01-landing-page.md
    ├── 02-auth-smoke.md
    └── 03-project-create.md
```

## Create and run saved coverage

Find your project, then create a test based on a scenario:

```bash
ta projects list --json
echo '{"title":"Landing page","steps":[{"title":"Open the landing page","type":"act"},{"title":"The main heading and primary call to action are visible","type":"assert"}]}' | ta tests create --project <projectId> --json
```

Use IDs returned by the commands. For development validation, save a
cloud-reachable preview or tunnel URL as an environment:

```bash
ta projects environments-create <projectId> --name Development --url https://dev.example.com --json
ta tests run <testId> --env development --wait --json
```

For a saved suite, find its group and run the group:

```bash
ta groups list --project <projectId> --json
ta tests run --group <groupId> --project <projectId> --env development --wait --json
```

`--wait` waits for validation to finish; without it, success only confirms that
the run was queued. Save JSON output locally when an artifact is useful:

```bash
ta tests run <testId> --env development --wait --json > result.json
```
