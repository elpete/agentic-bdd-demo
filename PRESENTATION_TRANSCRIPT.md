# Presentation Transcript: Agentic BDD/TDD

This is an example talk track for walking through the demo repo live. Treat it as a rehearsal script, not a word-for-word requirement.

## Before The Session

Open a terminal at the repo root:

```bash
cd /path/to/agentic-bdd-demo
box install
box server start
```

Leave the CommandBox server running. In another terminal tab:

```bash
box task run demo apply 00
box task run demo
```

Open these files in your editor:

- `DEMO_RUNBOOK.md`
- `readme.md`
- `.codex/guidelines.md`
- `.codex/skills/write-testbox-bdd-spec.md`
- `app/models/SessionDecisionService.bx`
- `tests/specs/unit/`

Open the app in a browser:

```text
http://127.0.0.1:42518
```

## Opening

Say:

> Today I want to show a testing workflow where the agent is useful, but not magical.
>
> The point is not "AI can write tests." We already know it can write something that looks like a test.
>
> The point is: can we make generated tests trustworthy? Can we use BDD, ColdBox context, and TestBox feedback to make tests a source of truth instead of a source of risk?

Show `readme.md`, especially the message:

```text
Tests are a source of truth, not a source of risk.
```

Say:

> The demo app is intentionally small: conference session review, CFP scoring, accepted / waitlisted / rejected decisions.
>
> Small enough to understand live, but real enough that generic tests miss important behavior.

## Step 0: Baseline Orientation

In the terminal:

```bash
box task run demo apply 00
```

Show:

- `app/models/SessionDecisionService.bx`
- `app/models/Session.bx`
- `tests/specs/unit/`
- `tests/specs/integration/`

Say:

> This is the baseline. The application exists. The domain exists. But the generated behavior specs are not active yet.
>
> That distinction matters. We are not starting from an empty toy. We are starting from code that has behavior, and then we are going to ask an agent to help us describe that behavior.

Point to `.ai/guidelines/custom/guidelines.md` and `.ai/skills/custom/write-testbox-bdd-spec.md`.

Say:

> Before the agent writes anything, we give it context.
>
> In a ColdBox app, context means conventions: where handlers live, how BoxLang classes are shaped, how TestBox BDD specs should read, how to avoid over-mocking, and what public behavior matters.
>
> This repo has that context checked in: guidelines, skills, and AI framework docs. In a real workflow, MCP-backed docs can keep that framework context current.

In the browser, open:

```text
http://127.0.0.1:42518
```

Say:

> The app starts. It is not a fake isolated unit test folder. This is a ColdBox app with a small workflow behind it.

## Step 1: The Intern Writes Tests

In the terminal demo menu, choose state `01`, or run:

```bash
box task run demo apply 01
```

Let the task show the saved prompt and response.

Say:

> Here is the first prompt. It sounds reasonable: generate TestBox BDD specs, follow conventions, focus on behavior.
>
> This is the intern version of agentic testing. It writes something useful quickly.

Show:

```text
tests/specs/unit/SessionDecisionServiceSpec.bx
```

Point out these examples:

```text
returns draft for a new session
returns accepted for a high-scoring submitted session
returns a decision struct with expected keys
```

Say:

> This is not garbage. It uses real domain objects. It has a draft case. It has a happy-path accepted case.
>
> But it is shallow. A high score of five does not prove the acceptance threshold. A decision struct shape assertion does not prove a business rule. And there is nothing here about conflicts, incomplete reviews, or minimum review count.

Run:

```bash
box run-script test:target
```

Say:

> The test passes. That is nice. It is not enough.
>
> Passing tests can still be a source of risk if they create false confidence.

## Step 2: Agent Audit Before Execution

Choose state `02`, or run:

```bash
box task run demo apply 02
```

Say:

> Before running deeper with generated code, I can ask the agent to audit what it created.
>
> This is one of the biggest shifts: the agent is not just a code generator. It can be a reviewer of its own work, if we give it standards to review against.

Show `.ai/responses/02-audit-before-running.md`.

Say:

> Notice what it calls out: exact threshold equality, minimum review count, incomplete reviews, conflicted reviews, and implementation-coupled assertions.
>
> That is the behavior hiding behind the generic first pass.

Run:

```bash
box run-script test:dry
```

Say:

> This is TestBox discovery. It is not a green test run. Nothing executed.
>
> What I get is inventory: one bundle, one suite, three specs. Before I trust generated tests, I want to know what TestBox thinks exists.

## Step 3: Give The Agent A Map

Choose state `03`, or run:

```bash
box task run demo apply 03
```

Let the prompt and response display.

Say:

> Now we give the intern a map.
>
> The important move is not just "write better assertions." The move is: write the BDD behavior map first.

Show `.ai/prompts/03-fix-bad-test-smells.md`.

Point to:

```text
Start by writing the BDD behavior map as describe / it names before filling in setup and assertions.
```

Say:

> I want the agent to name the behavior before it fills in mechanics.
>
> If the spec names are wrong, the code underneath will usually drift. If the spec names are right, the implementation has a contract to aim at.

Show `tests/specs/unit/SessionDecisionServiceSpec.bx`.

Point to examples:

```text
accepts a submitted session when the average equals the acceptance threshold
waitlists a submitted session when the average equals the waitlist threshold
rejects a submitted session below the waitlist threshold
waitlists an otherwise strong session until it has enough eligible reviews
ignores incomplete and conflicted reviews when calculating the final decision
```

Say:

> These names are doing work. They encode the business rules.
>
> The setup and expectations matter, but the BDD language is the first defense against generic boilerplate.

Run:

```bash
box run-script test:target
box run-script test:unit
```

Say:

> Now the targeted service specs pass, and the unit suite passes.
>
> More importantly, the suite has become capable of catching real mistakes.

## Step 4: TestBox 7 Dry-Run Discovery

Choose state `04`, or run:

```bash
box task run demo apply 04
```

Say:

> Step 4 does not change code. This is about workflow.
>
> TestBox 7 discovery lets me inspect what will run before I execute it. That is especially useful when an agent has just generated or rewritten suites.

Run:

```bash
box run-script test:dry
```

Point out:

```text
tests.specs.unit.SessionDecisionServiceSpec
6 specs

tests.specs.unit.SessionSpec
3 specs
```

Say:

> I am checking the suite names, spec count, and shape.
>
> Are there duplicates? Did it miss a behavior? Did the suite name drift? This is the code review before the code review.

Say:

> Discovery does not prove correctness. It proves structure. That is still valuable.

## Step 5: Fast Feedback Loop

Choose state `05`, or run:

```bash
box task run demo apply 05
```

Show:

```text
app/models/SessionDecisionService.bx
```

Point to:

```boxlang
if ( averageScore > variables.acceptanceThreshold )
if ( averageScore > variables.waitlistThreshold )
```

Say:

> This state introduces a real implementation bug: strict greater-than instead of greater-than-or-equal.
>
> This is exactly the sort of bug shallow happy-path tests miss.

Run:

```bash
box run-script test:target
```

Expected failure:

```text
Passed: 3
Failed: 3
Errors: 0
```

Say:

> Now the suite fails, and that is good news.
>
> The tests are not the risk here. The tests exposed the risk.

Point to the failures:

```text
Expected [accepted] but received [waitlisted]
Expected [waitlisted] but received [rejected]
Expected [accepted] but received [waitlisted]
```

Show `.ai/responses/05-debug-failing-spec.md`.

Say:

> The agent diagnoses the important question: is the test wrong, or is the implementation wrong?
>
> Here, the business rule says "meets the threshold." Equality counts. So we keep the tests and fix the implementation.

Say:

> This is the moment where BDD keeps the agent honest. We do not delete the failing spec to make the build green. We let the spec tell us what the system promised.

## Step 6: Collaborator, Not Oracle

Choose state `06`, or run:

```bash
box task run demo apply 06
```

Show:

- `app/models/SessionDecisionService.bx`
- `tests/specs/unit/SessionDecisionServiceSpec.bx`
- `tests/specs/unit/SessionSpec.bx`
- `tests/specs/integration/SessionsSpec.bx`

Point to:

```boxlang
if ( averageScore >= variables.acceptanceThreshold )
if ( averageScore >= variables.waitlistThreshold )
```

Say:

> Final state restores the known-good implementation and adds the integration spec.
>
> The unit specs prove the scoring rules. The integration spec proves ColdBox can reach the workflow.

Run:

```bash
box run-script test:dry
box run-script test:target
box testbox run outputFormats=mintext
```

Expected:

```text
10 specs
0 failures
0 errors
```

Show `.ai/prompts/06-review-final-suite.md` and `.ai/responses/06-review-final-suite.md`.

Say:

> The final prompt does not ask the agent to celebrate. It asks for a skeptical senior review.
>
> What is brittle? What is missing? Where are we overconfident?

Point to the response risks.

Say:

> This is the posture I want: the agent is a collaborator, not an oracle.
>
> It helped write tests. It helped audit tests. It helped diagnose a bug. But the tests and business language are what keep us grounded.

## Streaming Beat

If you want to show live streaming:

```bash
box run-script test:stream
```

If live output is noisy, show:

```text
.ai/demo-output/streaming-test-run.txt
```

Say:

> Streaming changes the rhythm. Instead of waiting for a final wall of output, the suite becomes conversational.
>
> Specs start, feedback appears, the agent can react, and the developer can decide whether the test or implementation is wrong.

## Closing

Say:

> The story is not that AI makes testing effortless.
>
> The story is that BDD gives AI something stable to work against.
>
> ColdBox context keeps it inside framework conventions. TestBox 7 gives us discovery, targeted runs, streaming feedback, and fast diagnosis. And the human developer still owns the judgment.
>
> AI can generate tests, but BDD plus framework-aware guidance makes those tests trustworthy.

Close with:

```text
Tests are a source of truth, not a source of risk.
```

