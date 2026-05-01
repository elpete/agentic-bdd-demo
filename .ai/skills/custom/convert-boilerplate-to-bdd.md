# Skill: Convert Boilerplate To BDD

When a generated spec feels generic:

1. Rewrite the `it` title as a business rule.
2. Split setup into readable Given / When / Then sections.
3. Replace vague data with domain-specific CFP review examples.
4. Keep one behavioral reason to fail per spec.
5. Remove assertions that only prove object plumbing.
6. Add at least one boundary or exclusion case if the behavior has thresholds or filtering.
