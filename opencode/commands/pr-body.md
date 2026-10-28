---
description: Draft or refresh the PR title and body for the current branch
---

Load the `easy-post-dev` skill and read its `references/pr-and-commit.md`. Then prepare the PR text for the current branch: $ARGUMENTS

1. Read what changed: `git log --oneline origin/main..HEAD` (use `origin/master` if that is the base) and `git diff --stat` against the base.
2. If a PR already exists, read it with `gh pr view --json number,title,body,url` and compare it with the code as it is now. List every place the text no longer matches.
3. Write the title and body using the sections in the reference, including a Release Test Plan with concrete canary scenarios, and link sibling PRs and the ticket.
4. Show me the text. Do not run `gh pr edit` or `gh pr create` until I say so.
