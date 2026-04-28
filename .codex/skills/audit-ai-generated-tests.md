# Skill: Audit AI-Generated Tests

Use this checklist before running generated tests:

- Do suite and spec names describe behavior a human stakeholder would recognize?
- Are there duplicate cases with different wording but the same assertion?
- Are edge cases meaningful or just boilerplate happy paths?
- Are any assertions coupled to private fields, helper methods, or sorting that the behavior does not require?
- Are mocks hiding the behavior under test?
- Would a real bug in threshold equality, minimum count, incomplete review handling, or conflict handling fail one of these specs?
- Is the targeted command documented so the next loop is fast?
