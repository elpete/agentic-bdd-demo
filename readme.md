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
box run-script demo:list
box run-script demo:next
box run-script demo:back
box run-script demo:apply 05
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
- `tests/resources/intentional-bug/SessionDecisionService.bx` contains the failing threshold implementation for Beat 4.
- `task.cfc` is the demo state controller. It can move forward/backward through the fake prompt sequence, apply code states, and print saved AI responses.

## Demo State Controller

```bash
box task run
box task run task.cfc apply 01
box task run task.cfc next
box task run task.cfc back
box task run task.cfc show 05
box task run task.cfc reset
```

Shortcut scripts are also available:

```bash
box run-script demo:list
box run-script demo:next
box run-script demo:back
box run-script demo:apply 05
box run-script demo:show 05
box run-script demo:reset
```

The task stores the current demo step in `.demo-state.json`, which is ignored by git.

## Current Known-Good State

The final suite should report:

```text
10 specs
10 passed
0 failed
0 errors
```

Use `DEMO_RUNBOOK.md` for the exact live sequence.
