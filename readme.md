# Agentic BDD/TDD Demo

Demo repo for Into the Box 2026: **Agentic BDD/TDD**.

The app is a small ColdBox 8 + BoxLang conference CFP scoring workflow. It is intentionally modest so the live demo can focus on the testing loop instead of framework ceremony.

## Message

AI can generate tests, but BDD plus framework-aware guidance makes those tests trustworthy. The final takeaway:

**Tests are a source of truth, not a source of risk.**

## Domain

- `Session` starts in draft and must have title, abstract, speaker, and category before submission.
- `Speaker` carries the required presenter identity.
- `Review` wraps reviewer state and conflict/submission status.
- `ScoreCard` scores clarity, relevance, originality, and confidence.
- `SessionDecisionService` decides accepted, waitlisted, or rejected from completed, non-conflicting reviews.

## Useful Commands

```bash
box install
box server start
box task run demo
box run-script demo:reset
box run-script test:dry
box run-script test:target
box run-script test:unit
box testbox run outputFormats=mintext
box run-script test:stream
```

TODO: The desired talk shorthand is `box test:dry` / `box test:unit`, but CommandBox 6.3.2 invokes package scripts with `box run-script <name>` unless local aliases are configured.

The app runs at:

```text
http://127.0.0.1:42518
```

## Demo Files

- `.codex/guidelines.md` gives the agent ColdBox/TestBox conventions.
- `.codex/skills/` contains small testing skills for the talk.
- `.ai/prompts/` contains paste-ready prompts.
- `.ai/responses/` contains saved idealized responses.
- `.ai/demo-output/streaming-test-run.txt` contains an offline streaming transcript.
- `tests/resources/demo-states/final/` contains the final known-good service and unit specs.
- `tests/resources/intentional-bug/SessionDecisionService.bx` contains the failing threshold implementation for Beat 4.
- `demo.cfc` is the demo state controller. It shows the current state inside the full state list and presents forward transitions as staged prompt/response walkthroughs.

## Demo State Controller

Run one command and use the menu:

```bash
box task run demo
```

The menu is the state list. The current state is highlighted. Choosing a later state walks forward through every intermediate state, types the saved prompt and response, pauses between sections, shows files changed, and exits. Choosing an earlier state applies that state, shows files changed, pauses once, and exits.

Shortcut scripts are also available:

```bash
box run-script demo:menu
box run-script demo:list
box run-script demo:next
box run-script demo:back
box run-script demo:pick
box run-script demo:apply 05
box run-script demo:show 05
box run-script demo:reset
```

The task stores the current demo step in `.demo-state.json`, which is ignored by git.

State `00` is the checked-in baseline: the CFP scoring code exists, but the AI-generated unit specs have not been created yet. Later demo states copy in the first-pass spec, improved specs, intentional bug, and final green files.

## Current Known-Good State

Restore the final green state first:

```bash
box run-script demo:reset
```

The final suite should report:

```text
10 specs
10 passed
0 failed
0 errors
```

Use `DEMO_RUNBOOK.md` for the exact live sequence.
