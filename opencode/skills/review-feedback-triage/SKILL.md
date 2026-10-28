---
name: review-feedback-triage
description: Evaluate review feedback (Copilot or a human) on a change. Verifies the claim against the code and framework behavior, decides whether it is a real regression, lays out options and drafts a reply. Use when given a PR review comment to assess or respond to.
---

# Review feedback triage

Goal: a verdict the user can act on, with evidence. Do not change code until they pick an option.

## 1. Restate the claim

One or two sentences: what is claimed to go wrong, where (file and line), and the stated impact. Quote the comment if short.

## 2. Verify the mechanism

- Read the cited code and its callers. Reproduce the reasoning, do not assume.
- For framework or library behavior, read the installed source or the version's docs, not memory. Gems live under the bundle path (`bundle show <gem>` equivalent), npm packages under `node_modules`, Python under the venv.
- Say plainly what is confirmed, what is partly right, what is wrong, and what could not be checked.

## 3. Does it apply here?

- Is the relevant behavior enabled in this runtime (caches, feature flags, config, deploy path)? Check configuration and, if needed, ask the user for the production value.
- Is the risky window real? How long, and who can trigger it?
- Is it **pre-existing**? Compare with the code before the change: did the old path have the same exposure, or did this change introduce or widen it? "Valid but not a regression" and "valid and new" are different answers.

## 4. Severity

Impact if it happens (data, money, security, noise), likelihood, and whether existing safeguards already cover it.

## 5. Options

List two or three, each with what it fixes, what it costs and what it leaves open. Give a recommendation and why. Include "do nothing, document" when that is honest.

## 6. How to test the fix

A regression test that fails without the fix. If the reviewer's suggested test is impractical (for example needs a second DB connection under transactional specs), propose an equivalent that observes the mechanism directly (for example subscribing to `sql.active_record` and asserting no cached read).

## 7. Reply draft

A short comment for the thread: acknowledge, state the verdict with one line of evidence, state the action taken or chosen. Do not post it unless asked.

## Output template

```
Claim: ...
Verdict: valid / partly valid / not applicable (pre-existing: yes/no)
Evidence: ...
Impact: ...
Options: 1) ... 2) ... (recommended: N because ...)
Test: ...
Reply draft: ...
```
