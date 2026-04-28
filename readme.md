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

## Current Known-Good State

The final suite should report:

```text
10 specs
10 passed
0 failed
0 errors
```

Use `DEMO_RUNBOOK.md` for the exact live sequence.
