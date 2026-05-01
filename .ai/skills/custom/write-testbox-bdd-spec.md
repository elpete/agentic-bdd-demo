# Skill: Write TestBox BDD Specs

When asked to add TestBox specs:

1. Read the public behavior first.
2. Sketch the BDD behavior map first: `describe` and `it` names should be readable before setup code exists.
3. Fill in Given / When / Then setup only after the behavior names describe the contract.
4. Name suites by business capability, not class internals.
5. Use real domain objects unless the test crosses a slow or external boundary.
6. Prefer edge cases that would change a real CFP decision:
   - exact acceptance threshold
   - exact waitlist threshold
   - minimum review count
   - incomplete reviews
   - conflicted reviews
   - draft versus submitted sessions
7. Avoid assertions against private helpers, variable names, or implementation order.
8. Run dry-run/discovery before execution when changing suite structure.
9. Run the narrowest useful TestBox command before the full suite.
