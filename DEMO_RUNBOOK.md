# Demo Runbook

## Setup

Open the repo:

```bash
cd /Users/elpete/Developer/github/elpete/agentic-bdd-demo
box install
box server start
```

Open:

- `README.md`
- `.codex/guidelines.md`
- `app/models/SessionDecisionService.bx`
- `tests/specs/unit/SessionDecisionServiceSpec.bx`

Expected app URL:

```text
http://127.0.0.1:42518
```

## Beat 1: The Intern Writes Tests

Show:

- `.ai/prompts/01-generate-first-spec.md`
- `.ai/responses/01-generate-first-spec.md`

Paste prompt:

```text
Generate TestBox BDD specs for SessionDecisionService.
Follow project conventions.
Focus on behavior, not implementation details.
```

Point out:

- Useful status coverage.
- A few shallow cases.
- One assertion that might be public-output useful or implementation-coupled depending on the API contract.

## Beat 2: Give The Agent A Map

Show:

- `.codex/guidelines.md`
- `.codex/skills/write-testbox-bdd-spec.md`
- `.codex/skills/convert-boilerplate-to-bdd.md`
- `.ai/prompts/03-fix-bad-test-smells.md`
- `.ai/responses/03-fix-bad-test-smells.md`

Command:

```bash
box run-script test:target
```

Expected output shape:

```text
tests.specs.unit.SessionDecisionServiceSpec
Passed: 6
Failed: 0
Errors: 0
```

Point out:

- Better test names.
- Exact boundary values.
- Incomplete and conflicted reviews.

## Beat 3: Audit Before Execution

Show:

- `.ai/prompts/02-audit-before-running.md`
- `.ai/responses/02-audit-before-running.md`
- `.ai/prompts/04-use-dry-run-discovery.md`
- `.ai/responses/04-use-dry-run-discovery.md`

Command:

```bash
box run-script test:dry
```

Expected output shape:

```text
tests.specs.unit.SessionDecisionServiceSpec
SessionDecisionService
6 specs discovered
```

TODO: `box testbox run options:dryRun=true` currently reaches the TestBox 7 runner but CommandBox 6.3.2 expects normal execution totals and errors with `key [TOTALFAIL] doesn't exist`. Use `box run-script test:dry`, which calls the dry-run runner endpoint directly, until the CLI parser/syntax is updated.

Demo point:

```text
Dry-run is the code review before the code review.
```

## Beat 4: Fast Feedback Loop

Create the intentional failing state:

```bash
cp tests/resources/intentional-bug/SessionDecisionService.bx app/models/SessionDecisionService.bx
box run-script test:target
```

Expected failure:

```text
accepts a submitted session when the average equals the acceptance threshold
expected accepted but received waitlisted or rejected
```

Show:

- `.ai/prompts/05-debug-failing-spec.md`
- `.ai/responses/05-debug-failing-spec.md`

Fix:

```text
Change strict threshold comparisons from > to >=.
```

Return to known-good quickly:

```bash
git checkout -- app/models/SessionDecisionService.bx
box run-script test:target
```

If this is not a git repo yet, manually change both threshold comparisons in `app/models/SessionDecisionService.bx` back to `>=`.

## Beat 5: Streaming Feedback Changes The Rhythm

Show:

- `.ai/demo-output/streaming-test-run.txt`

Command:

```bash
box run-script test:stream
```

Expected shape:

```text
tests discovered
individual specs starting
one failure
fix
rerun
green suite
```

If streaming output is noisy or the venue network slows the demo, show the saved transcript. The repo is reliable offline because the transcript and AI responses are checked in.

## Beat 6: Collaborator, Not Oracle

Show:

- `.ai/prompts/06-improve-with-bdd-language.md`
- `.ai/responses/06-improve-with-bdd-language.md`
- `tests/specs/integration/SessionsSpec.bx`

Command:

```bash
box testbox run outputFormats=mintext
```

Expected final state:

```text
Passed: 10
Failed: 0
Errors: 0
```

Close with:

```text
Tests are a source of truth, not a source of risk.
```

## Reset Instructions

```bash
git checkout -- app/models/SessionDecisionService.bx
box server restart
box testbox run outputFormats=mintext
```

If there is no git history:

1. Open `app/models/SessionDecisionService.bx`.
2. Ensure both decision threshold checks use `>=`.
3. Run `box run-script test:target`.

## If A Command Fails

- `Connection refused`: run `box server start` and retry.
- `Address already in use`: run `box server stop`, then `box server start`.
- Dry-run CLI parser error: use `box run-script test:dry`.
- BoxLang reserved-scope weirdness: check for local variables named `session`, `request`, `application`, `url`, or `form`.
- Noisy streaming output: show `.ai/demo-output/streaming-test-run.txt`.
