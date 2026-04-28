# Skill: Write TestBox BDD Specs

When asked to add TestBox specs:

1. Read the public behavior first.
2. Name suites by business capability, not class internals.
3. Use real domain objects unless the test crosses a slow or external boundary.
4. Prefer edge cases that would change a real CFP decision:
   - exact acceptance threshold
   - exact waitlist threshold
   - minimum review count
   - incomplete reviews
   - conflicted reviews
   - draft versus submitted sessions
5. Avoid assertions against private helpers, variable names, or implementation order.
6. Run dry-run/discovery before execution when changing suite structure.
7. Run the narrowest useful TestBox command before the full suite.
