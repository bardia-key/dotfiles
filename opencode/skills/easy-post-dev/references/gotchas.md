# Gotchas

Each rule has the incident behind it, so judge when it applies instead of pattern matching.

## Working habits (all repos)

- **Edit and test in the same parallel block race.** Tests ran against the old code and a "pass" or "fail" was reported for the wrong version. Do edits, then run tests in a later step.
- **Pass explicit paths to `git add`, and check it.** `git add a b c` aborts completely when one pathspec no longer matches (a file already staged as deleted), so an amend silently missed code changes. After any commit, `git show --stat` it.
- **Base branches differ.** easy_post uses `main`; the web repos use `master`. `git fetch origin <base>` and branch from `origin/<base>`.
- **A stash round-trip unstages everything.** After `git stash` / `git stash pop`, staged deletions and renames become unstaged; re-stage before committing.
- **Never extend baselines to make lint pass** (`.rubocop_todo.yml`).

## easy_post (Rails monolith)

### Cassettes (VCR)
- Cassette files are named after the describe/context/it strings (`spec/cassettes/<spec path>/<Names_joined_with_underscores>.json`; a trailing space becomes a trailing `_`). Renaming an example orphans its cassette, and CI's `check-unused-cassettes` fails on orphans. Rename the cassette file with `git mv` or do not rename.
- Deleting an example orphans its cassette too: delete the cassette in the same change. Find them with `git ls-files spec/cassettes | grep -i '<words from the example name>'`.
- Examples under `vcr: :users` (or similar) that have no cassette try to record, fail offline, and leave junk files. Delete untracked ones: `git ls-files --others --exclude-standard spec/cassettes`.
- New examples should not need cassettes: use `:mock_users` with `vcr: false`. Limits of the mock: it does not implement `presentable_api_keys` (the index endpoint), and the `:referral_customer` factory needs a live Connect service.
- Never pass `:allow_unused_http_interactions`.
- Adding an expectation to an existing example is fine (same cassette). Changing its description is not.

### Lint
- `make lint` runs rubocop on whole files changed in the committed diff (`origin/main...HEAD`), and CI runs the same. Pre-existing offenses in a file you touch fail the PR, so fix them in that file.
- `Style/NegatedIf` pushes toward `unless`; the house style avoids both, so extract a positive predicate method.
- `Easypost/FeatureStubbing`: use `enable_feature` / `disable_feature`, not `allow(Feature::...)`.
- `RSpec/PendingWithoutReason`: use `context '...', skip: 'reason'`, not `xcontext`. Autocorrect single cops with `rubocop -a --only <Cop>`; layout cops cascade, so repeat until clean.

### Feature flags
- The `features/` YAML files are dev/test defaults. `deploy-hooks/build` deletes them. Production values live in the Features service: `features-cli get features/easypost/<group>/<name>.yaml | jq`. Ask the user for the value; do not guess.
- Semantics (toggles gem): `enabled_for?` means the rule matches; `disabled_for?` is the opposite. `in: [ids]` = only those; `not: in: [ids]` = everyone except those; `lt: 0` = nobody; `gt: 0` = everybody.
- Removing a flag also removes: the yml, the specs and contexts that toggled it, and the cassettes of deleted examples.

### Caching
- Rails 8 caches identical non-locked SELECTs per request (including `find_by`). Only writes on the same connection clear the cache. A second `find_by(user_id:)` after the service constructor returns the construction-time row. Use `ApplicationRecord.uncached { ... }` for a fresh read. Verify by subscribing to `sql.active_record` and checking `payload[:cached]`.

### Billing
- `UserBalanceService#ensure_funds!` has side effects: it takes the wallet lock and recharges (charging the saved card), notifies, runs `monitor_spend` (CustomerAnalytics, fraud alerts, `PURCHASE_NOT_ALLOWED`) and emails support when a credit line is exhausted. For a read-only question use `soft_funds_available?` (advisory, no lock, no concurrency guarantee).
- The wallet has no floor: `withdrawal` just decrements. `Wallet::WalletRepository.find_by` raises `NOT_FOUND` for a missing wallet.
- `StripeCustomer#credit_line_available?` emails support when exceeded; `credit_line_covers?` does not.

### Auth
- `authentication_method.web_session?` comes from the `X-EasyPost-Authentication-Method: web-session` header that easypost-web-backend sends, handled in `SessionsHelper#set_current_user_context` (needs a private source IP and a source service header). `AuthenticationMiddleware` is not mounted.

### Environment
- `bundle` is not on PATH; use `vendor/bundle/bundle exec` (the Makefile's `BUNDLER`).
- A branch with a different `Gemfile.lock` needs `vendor/bundle/bundle install`, which needs registry credentials (`BUNDLE_DL__CLOUDSMITH__IO`). Without them, report it; do not swap lockfiles.
- `PendingMigrationError` means the test DB is behind: `make test-db`.
- Make test filtering: `make test TARGET="spec/x_spec.rb:123"`; for several files, quote the list.

## easypost-web-backend (Flask, justfile)

- Business logic goes in `api/repos/`, not route handlers. Tests mirror `api/` under `tests/`.
- `just lint` = black, isort, mypy, bandit, flake8; line length 120.
- Route, response shape and error changes need a matching easypost-web-app change (see its `AGENTS.md`).
- Prefer mocking over recording cassettes. `user_flags_mock` and `user_and_agent_values_mock` are the fixtures for flags and auth.
- The venv comes from `just _venv_requirements_installed _venv_test_requirements_installed`. Do not use `just install` (it drops the databases).
- Proxy routes forward `X-EasyPost-*` headers via `public_proxy`; the gate for a feature belongs in the monolith, not in the proxy.

## easypost-web-app (Next.js, justfile)

- `just install-modules` for dependencies; `just install` also sets up submodules and git hooks.
- `just lint` ends with `tsc`; without the submodules it reports a missing `shared-datafiles` JSON, which also fails on an unmodified checkout. Say so instead of treating it as caused by the change.
- Prettier in `just lint` covers `./src` only. Run `npx prettier --check <file>` for Cypress files and fixtures.
- Stage explicit files. A pre-commit hook can re-add submodule pointers (`src/static/shared-assets`) from a stale checkout.
- Cypress specs cannot run locally; say they were not run.
