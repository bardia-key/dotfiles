---
description: Run the EasyPost verification pass (lint, touched tests, cassette check) and report the result
---

Load the `easy-post-dev` skill if it is not loaded, then run the verification script from the repository root:

`bash ~/.config/opencode/scripts/easy-post-verify.sh $ARGUMENTS`

Report the summary lines exactly (PASS, WARN, FAIL and the final result). For each FAIL or WARN, say what it means and the smallest in-scope fix. Do not claim the work is done unless the result shows 0 fail, and do not edit files outside the scope of the current task to make it pass. Pass `--grep 'regex'` to also prove removed symbols are gone, `--no-tests` to skip the test run, and `--preflight` to check only the environment.
