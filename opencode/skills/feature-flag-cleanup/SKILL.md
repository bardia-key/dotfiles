---
name: feature-flag-cleanup
description: Remove a feature flag (toggles YAML flag) from an EasyPost repo using the real production value as evidence. Use when asked to remove, retire or clean up a feature flag or to remove code behind a flag that is on or off for almost no users.
---

# Feature flag cleanup

Load `easy-post-dev` first. This is the procedure; do not skip the evidence step.

## 1. Get the production value

Ask the user to run `features-cli get features/easypost/<group>/<name>.yaml | jq` and paste the result. The files under `features/` in the repo are dev and test defaults and say nothing about production. Never guess.

## 2. Work out the live side

| Rule | Meaning |
|---|---|
| `user_id: in: [ids]` | enabled only for those ids |
| `user_id: not: in: [ids]` | enabled for everyone except those ids |
| `user_id: lt: 0` | enabled for nobody |
| `user_id: gt: 0` | enabled for everybody |

Remember `enabled_for?` means the rule matches and `disabled_for?` is its opposite.

- If the matched ids are few, ask whether those users are active (disabled or deleted accounts do not count). Mention anything the evidence does not settle.
- Decide the live side: for almost everyone is the flag effectively **on** or **off**? The code path for that side stays; the other side is dead.
- If the flag affects billing, auth or data access, list the exact users that still take the dead path and say what happens to them.

## 3. Find every use

```bash
git grep -n -E 'ClassName|flag_name' -- . ':!spec/cassettes' ':!tests/cassettes'
```

Check the `Feature::Group::Name` constant form, `Feature.enabled?(:group, :name, ...)`, spec helpers (`enable_feature`, `disable_feature`) and docs. Also check other repos that could read the same flag.

## 4. Remove

1. Code: keep the live branch, delete the dead one and any condition that only existed for the flag. Keep surrounding guards that are still true for other reasons (for example, a disabled-user check that makes a flag check redundant; mention it).
2. The flag file under `features/`.
3. Specs: delete examples and contexts that test the dead path; remove only the toggle lines from contexts that test something else, then confirm their assertions still hold.
4. Cassettes belonging to deleted examples (`git ls-files spec/cassettes | grep -i <words>`).
5. Do not rename remaining examples (cassette names).

## 5. Verify

```bash
bash ~/.config/opencode/scripts/easy-post-verify.sh --grep 'ClassName|flag_name'
```

This lints the whole touched files (fix existing offenses there; CI will fail otherwise), runs the touched specs, flags stray cassettes and proves no references remain. Run any other specs that go through the changed code.

## 6. Write it up

- Commit message: "Remove the <Name> feature flag", the production rule as evidence, who is affected, what else was cleaned.
- PR Release Test Plan: one canary user per remaining code path (see `easy-post-dev` `references/pr-and-commit.md`).
- Follow-up: the flag in the Features service can be deleted once nothing reads it. Say so; do not do it.
