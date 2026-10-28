# Commits, PRs and Release Test Plans

## Rules

- Do not `git commit`, `--amend`, `git push` or `gh pr edit` unless asked. Ask whether to amend or add a new commit when a change belongs to an existing commit.
- Stage explicit paths. After committing, confirm with `git show --stat` and `git status`.
- One concern per PR. Refactor, flag removal and behavior change are separate PRs, each referencing the others.
- Branch names: always `bardia/<topic>`, or `bardia/<TICKET>-<topic>` when there is a ticket (`bardia/EP-109-whoami-cleanup`). Never create a branch without the `bardia/` prefix. Repos that ask for ticket-based names are satisfied by putting the ticket after the prefix.

## Commit messages

Use the style the user asks for. If they say "brief", write a one-line title plus at most two short sentences. Otherwise:

```
<Title: what, in the imperative>

## Why
The problem and why it matters. Name the incident or the evidence.

## What changed
- the behavior-level changes, file or method by name

## Behavior notes
- anything that behaves differently, including edge cases that changed

## Tests
- what was added or removed, and what was run (counts, lint result)

## Follow-ups
- remaining phases, flags to delete outside the repo, deploy order
```

Reference related PRs, plan docs and tickets by URL. For phased work, name the phase ("Phase 2 of EP-109") and link the earlier phases.

## PR body

Keep it identical in substance to the final code. After every push that changes the design, re-read the body (`gh pr view <n> --json title,body`) and update it (asking first).

Sections: Why, What changed, Behavior notes, Tests, Release Test Plan, Related.

### Release Test Plan (required on every PR)

"No risk" is not a category. Include:

1. **Risk**: low / medium / high and why.
2. **Deploy and rollback**: the exact steps (`srvctl` commands for the monolith, the usual deploy for the web repos) and how to roll back. Say if order matters relative to other PRs.
3. **Scenarios to verify on canary**, by real user type, one per code path touched. Use concrete user ids when known, for example one account per branch of a billing rule (credit-line user, real-time-billing-disabled user, negative-threshold user), and "general traffic on <the aggregate endpoint> is clear".
4. **What to watch**: error rates, specific log or metric names.

### Related

Ticket link, sibling PRs (monolith, web-backend, web-app), the plan doc path.

## Plan docs

For phased work, write `plans/<TICKET>.md` in the primary repo and commit it with the first PR. Keep the target behavior table, phase list, deploy order, risks and open decisions current as phases land.
