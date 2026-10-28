# Global working agreements

- Use the edit tool for file changes. Do not change tracked files through the shell: `sed -i` is blocked by policy, and also avoid `perl -pi`, `python -c` and redirects into repo files.
- Do not put an edit and a test, lint or build command in the same parallel tool block; they race and report stale results.
- Do not run `git commit`, `--amend`, `git push` or `gh pr edit` unless asked.
- Always create new branches with the `bardia/` prefix (`git checkout -b bardia/<topic>`, or `bardia/<TICKET>-<topic>` when there is a ticket, for example `bardia/EP-109-whoami-cleanup`). Never create a branch without it, and branch from the remote base (`origin/main` or `origin/master`). If a repo's guidance asks for ticket-based names, put the ticket after the prefix.
- Use a repo's own Makefile or justfile targets (`make help`, `just --list`) before hand-built tool commands.
- In any EasyPost repo (easy_post, easypost-web-backend, easypost-web-app, and similar), load the `easy-post-dev` skill before changing code. Also load `feature-flag-cleanup` to remove a flag, `review-feedback-triage` to assess review comments, and `multi-repo-rollout` when a change spans repos.
