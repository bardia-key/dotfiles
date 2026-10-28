---
name: multi-repo-rollout
description: Plan and execute a change that spans more than one repo or deployable (an API or rule in one service, consumers in others, flags or fields to clean up afterwards). Works for any set of repos. Use when a change touches a contract that other repos or services read, or when asked for a phased plan, deploy order or cleanup phase.
---

# Multi-repo rollout

Repo-agnostic. Name the repos from the task; do not assume which they are.

## 1. Map the contract

Ask or find out, and write down:

- **What changes?** The rule, endpoint, field, flag, header, schema or permission.
- **Who owns it?** The repo whose behavior is the source of truth (the producer).
- **Who consumes it?** Every repo, service or client that reads it. Search each checkout for the symbol or path (`git grep` across sibling directories, `gh search code` if available). Include UI clients, proxies and docs.
- **Where should the logic finally live?** One place, normally the producer. Duplicated gates in consumers are removed at the end.

If the user's description leaves any of these open, ask before planning.

## 2. Choose the compatibility strategy

Default to **expand, migrate, contract**:

1. **Expand**: the producer gains the new behavior in a way old consumers survive.
2. **Migrate**: consumers move to the new behavior, one at a time.
3. **Contract**: remove the old behavior, compat fields and duplicated gates only after every consumer is deployed and no longer reads them.

State for each step whether it is safe to deploy in any order or has a required position.

## 3. Phase plan

For each phase give: repo, the change, what it depends on being deployed, how to verify, how to roll back, and what breaks if it ships early or late. Typical order:

1. Producer change (new behavior, old behavior still accepted).
2. Remove duplicated enforcement in intermediaries, once the producer is live.
3. Consumers (UI, clients) stop depending on the old behavior.
4. Cleanup: delete compat fields, flags and dead paths. This phase must come last; before it, search every consumer for remaining reads of what is being removed.

Write down the early or late failure for each ordering, for example "removing a field before consumers stop reading it hides their pages", "enabling a gate before the producer enforces it leaves a window with no gate".

## 4. Write the plan

Put `plans/<TICKET>.md` in the primary repo: goal, target behavior table, phases with order and rollback, risks, open decisions. Keep it current as phases land. Open questions go in the plan and to the user, not into assumptions.

## 5. Execute phase by phase

- One branch and one PR per phase per repo. Do not mix phases.
- Each PR body and commit says "Phase N of <TICKET>", links the other phases' PRs, and states the deploy order and what must be live first.
- Follow `easy-post-dev` for tests, verification and commit rules inside each repo.
- Before the cleanup phase, confirm with the user that earlier phases are deployed in production, and re-run the consumer search.

## 6. Check before each deploy

- Is everything this phase depends on already live?
- Does any consumer still need what this phase removes?
- Is rollback possible without another repo changing?

## Illustration

A rule change moved a gate into a core service: (1) core service enforces the new rule, (2) a proxy drops its duplicate gate, (3) the web app drops its UI gates, (4) the proxy later drops the compat flags the web app used to read. Phase 4 had to wait until phase 3 was live, otherwise pages hidden by the flag would disappear for everyone.
