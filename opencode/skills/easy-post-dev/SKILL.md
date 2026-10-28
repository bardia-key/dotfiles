---
name: easy-post-dev
description: Process and guardrails for working in any EasyPost repo (easy_post Rails monolith, easypost-web-backend, easypost-web-app, and similar). Load it before changing code, running tests or lint, committing, or writing a PR in an EasyPost repo.
---

# EasyPost development process

Evidence first, small isolated changes, verified before "done". Read the reference you need:

- `references/gotchas.md`: repo quirks, each with the incident behind it. Read before touching tests, cassettes, lint, feature flags, caching, billing or auth.
- `references/pr-and-commit.md`: commit message and PR body formats, the Release Test Plan.

## 1. Use the repo's own targets

Most EasyPost repos ship a Makefile or justfile. Use those targets, not hand-built tool commands.

1. Discover them first: `make help`, `just --list`, or `grep -E '^[a-z_-]+:' Makefile`.
2. Known targets:
   - easy_post (Ruby): `make test TARGET="spec/a_spec.rb spec/b_spec.rb:42"`, `make lint` (rubocop on whole files changed vs origin/main), `make testmine`, `make test-db` (pending migrations), `make routes`.
   - easypost-web-backend (Python): `just test tests/x/test_y.py`, `just lint`, `just coverage` (90% minimum), `just routes`. Not `just install`: it drops and recreates the databases.
   - easypost-web-app (JS): `just test <path>`, `just lint` (eslint, prettier on `./src`, tsc), `just install-modules`.
3. Call `rspec`, `pytest` or `jest` directly only when no target exists. In Ruby use the repo's bundler wrapper (`vendor/bundle/bundle exec`), not a bare `bundle`.
4. If a target fails on setup (missing gems, no venv, no node_modules, pending migrations), report the exact fix instead of working around it. `bash ~/.config/opencode/scripts/easy-post-verify.sh --preflight` names the fix.

## 2. Before changing anything

Answer these from evidence, not memory:

1. What does production do today? For anything behind a feature flag, ask for the real value (`features-cli get ...`); the in-repo flag files are only dev defaults.
2. Who calls this? Search callers in every repo that could consume it.
3. What side effects does the helper I want to reuse have (locks, charges, emails, notifications, caches)?
4. Does a cache, lock or ordering issue apply?
5. Can this be its own PR? Refactors, flag removals and behavior changes are separate PRs.
6. Does it cross repos? If yes, load `multi-repo-rollout`.

## 3. While writing

- Guard clauses, one line each: `return x if y`. No `||` or `&&` chains of three or more predicates in a condition; name them with small predicate methods.
- No `unless`, and no `if !x`. Extract a positively named predicate instead.
- Use existing helpers (`Mode.production?(mode)`) over conversions and manual comparisons.
- `rescue` around the exact call that can raise, not around the whole method.
- Match the surrounding comment density. Comment only non-obvious behavior.
- No shared abstraction until a second caller exists. When one is needed, extract it in its own behavior-preserving PR.
- Stay in scope. Do not touch rules or code you were not asked to change.
- Edit with the edit tool. Never change tracked files through the shell (`sed -i` is denied by policy; also no `perl -pi`, `python -c`, redirects).
- Never put an edit and a test, lint or verify command in the same parallel tool block: they race and report stale results.

## 4. Tests

- Assert real behavior. Delete NOOP tests.
- A new test must fail without the fix: remove or break the fix, run the test and watch it fail, then restore (edit and run in separate steps).
- Respect the cassette rules in `references/gotchas.md` before adding, renaming or deleting an example.
- Lint every touched file whole. Fix pre-existing offenses in files you touch; do not extend baselines.

## 5. Verify before saying done

```bash
bash ~/.config/opencode/scripts/easy-post-verify.sh            # lint + tests for touched files + cassette check
bash ~/.config/opencode/scripts/easy-post-verify.sh --grep 'RemovedSymbol|removed_flag'
```

Or run `/verify`. Paste the result summary, including any WARN lines. Do not claim success without it.

## 6. Commit, push, PR

- Never run `git commit`, `--amend`, `git push` or `gh pr edit` unless asked.
- Stage explicit paths. A failing pathspec aborts the whole `git add`, so check its result. After committing, run `git show --stat` and confirm the tree is clean.
- Follow the message style requested (brief or detailed). Reference related PRs, plan docs and tickets.
- Keep the PR title and body in sync with the code after every push. Formats are in `references/pr-and-commit.md`.

## 7. Related skills

- `feature-flag-cleanup`: removing a feature flag.
- `review-feedback-triage`: evaluating Copilot or human review comments.
- `multi-repo-rollout`: phased changes across repos.
