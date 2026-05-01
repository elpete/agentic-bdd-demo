# Demo Runbook

This repo is designed to be cloned and run offline. The checked-in code starts at
demo state `00`: the app and domain models exist, but the AI-generated unit specs
are not active yet.

## Setup

```bash
cd /path/to/agentic-bdd-demo
box install
box server start
box task run demo list
```

Expected app URL:

```text
http://127.0.0.1:42518
```

Open these files before starting:

- `app/models/SessionDecisionService.bx`
- `.codex/guidelines.md`
- `.codex/skills/write-testbox-bdd-spec.md`
- `.ai/prompts/`
- `.ai/responses/`

At state `00`, `tests/specs/unit/` should only contain `.gitkeep`.

## Demo Controller

Use the interactive menu:

```bash
box task run demo
```

Controls:

- Up/Down moves through states.
- Enter applies the highlighted state.
- `1` through `6` jumps directly to that step.
- `q` quits.

Direct commands are available when you want less ceremony:

```bash
box task run demo list
box task run demo apply 01
box task run demo next
box task run demo back
box task run demo reset
```

Forward transitions type the saved prompt, wait, type the saved AI response,
show files changed, then wait again. Backward transitions only apply files,
show files changed, wait once, and exit.

## State Map

| State | Purpose | Active code after state |
| --- | --- | --- |
| `00` | Baseline before AI tests | App code only; no active generated unit specs |
| `01` | First generated spec | `SessionDecisionServiceSpec.bx` only, shallow first pass |
| `02` | Audit before running | No file changes from `01` |
| `03` | Better BDD coverage | Final service spec plus `SessionSpec.bx` |
| `04` | Dry-run discovery | No file changes from `03` |
| `05` | Intentional failure | Same specs as `03`, service has strict `>` bug |
| `06` | Final green review | Fixed service plus final unit specs |

The final green unit specs live in `tests/resources/demo-states/final/`.
The first generated spec lives in `tests/resources/demo-states/01-first-spec/`.

## Step 0: Baseline Orientation

Command:

```bash
box task run demo apply 00
```

Show:

- `app/models/SessionDecisionService.bx`
- `app/models/Session.bx`
- `tests/specs/unit/`

Expected active files:

```text
tests/specs/unit/.gitkeep
```

Talk track:

- The app has real CFP scoring behavior.
- The service is intentionally under-tested at the start.
- The point is not "AI writes tests"; the point is giving the agent a behavior map.

Do not run `box run-script test:target` yet. The target spec does not exist in
state `00`.

## Step 1: The Intern Writes Tests

Command:

```bash
box task run demo apply 01
```

The task shows:

- `.ai/prompts/01-generate-first-spec.md`
- `.ai/responses/01-generate-first-spec.md`

Expected active files:

```text
tests/specs/unit/SessionDecisionServiceSpec.bx
```

Expected first-pass coverage:

```text
SessionDecisionService
  returns draft for a new session
  returns accepted for a high-scoring submitted session
  returns a decision struct with expected keys
```

Optional command:

```bash
box run-script test:target
```

Talking points:

- It is useful, but shallow.
- It misses exact threshold boundaries.
- It misses incomplete/conflicted review exclusion.
- The decision-shape assertion is a mild test smell.

## Step 2: Audit Before Running

Command:

```bash
box task run demo apply 02
```

No files should change from state `01`.

The task shows:

- `.ai/prompts/02-audit-before-running.md`
- `.ai/responses/02-audit-before-running.md`

Optional discovery command:

```bash
box run-script test:dry
```

Expected discovery shape:

```text
tests.specs.unit.SessionDecisionServiceSpec
  3 specs
```

Talking point:

```text
Dry-run is the code review before the code review.
```

## Step 3: Give The Agent A Map

Command:

```bash
box task run demo apply 03
```

The task shows:

- `.ai/prompts/03-fix-bad-test-smells.md`
- `.ai/responses/03-fix-bad-test-smells.md`

Expected active files:

```text
tests/specs/unit/SessionDecisionServiceSpec.bx
tests/specs/unit/SessionSpec.bx
```

Expected service-spec behavior:

```text
accepts a submitted session when the average equals the acceptance threshold
waitlists a submitted session when the average equals the waitlist threshold
rejects a submitted session below the waitlist threshold
waitlists an otherwise strong session until it has enough eligible reviews
ignores incomplete and conflicted reviews when calculating the final decision
```

Command:

```bash
box run-script test:target
```

Expected:

```text
6 specs
0 failures
0 errors
```

Talking points:

- BDD names now encode business rules.
- Boundary values are explicit.
- The tests describe what must be excluded from final decisions.

## Step 4: Dry-Run Discovery

Command:

```bash
box task run demo apply 04
```

No files should change from state `03`.

The task shows:

- `.ai/prompts/04-use-dry-run-discovery.md`
- `.ai/responses/04-use-dry-run-discovery.md`

Command:

```bash
box run-script test:dry
```

Expected final discovery shape:

```text
tests.specs.unit.SessionDecisionServiceSpec
  6 specs
tests.specs.unit.SessionSpec
  3 specs
No integration specs are active yet; that comes in step `06`.
```

TODO: Direct `box testbox run options:dryRun=true` currently reaches dry-run
but CommandBox 6.3.2 expects normal execution totals and errors with
`key [TOTALFAIL] doesn't exist`. Use `box run-script test:dry` for the demo.

## Step 5: Fast Feedback Loop

Command:

```bash
box task run demo apply 05
```

Expected active change:

```text
app/models/SessionDecisionService.bx
```

The service intentionally uses strict threshold checks:

```boxlang
if ( averageScore > variables.acceptanceThreshold )
if ( averageScore > variables.waitlistThreshold )
```

Command:

```bash
box run-script test:target
```

Expected failure:

```text
accepts a submitted session when the average equals the acceptance threshold
expected accepted but received waitlisted or rejected
```

Talking points:

- The test is not the problem.
- The business rule says threshold equality counts.
- Keep the test; fix the implementation.

## Step 6: Collaborator, Not Oracle

Command:

```bash
box task run demo apply 06
```

Expected active files:

```text
app/models/SessionDecisionService.bx
tests/specs/unit/SessionDecisionServiceSpec.bx
tests/specs/unit/SessionSpec.bx
tests/specs/integration/SessionsSpec.bx
```

The service should be fixed:

```boxlang
if ( averageScore >= variables.acceptanceThreshold )
if ( averageScore >= variables.waitlistThreshold )
```

Commands:

```bash
box run-script test:target
box testbox run outputFormats=mintext
```

Expected final state:

```text
10 specs
0 failures
0 errors
```

Show:

- `.ai/prompts/06-improve-with-bdd-language.md`
- `.ai/responses/06-improve-with-bdd-language.md`
- `tests/specs/integration/SessionsSpec.bx`

Close with:

```text
Tests are a source of truth, not a source of risk.
```

## Streaming Beat

Use this when you want to show the rhythm change without relying on live output:

```bash
box run-script test:stream
```

Fallback transcript:

```text
.ai/demo-output/streaming-test-run.txt
```

## Reset Instructions

Return to final green:

```bash
box task run demo reset
box testbox run outputFormats=mintext
```

Return to the beginning of the story:

```bash
box task run demo apply 00
```

If commands fail:

- `Connection refused`: run `box server start` and retry.
- `Address already in use`: run `box server stop`, then `box server start`.
- Dry-run parser error: use `box run-script test:dry`.
- Noisy streaming output: show `.ai/demo-output/streaming-test-run.txt`.
