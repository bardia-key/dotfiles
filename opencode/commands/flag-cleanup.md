---
description: Remove a feature flag using the production value as evidence
---

Load the `easy-post-dev` and `feature-flag-cleanup` skills, then clean up the feature flag: $ARGUMENTS

Start by asking me for the production value of the flag (`features-cli get features/easypost/<group>/<name>.yaml | jq`) unless I already gave it. Do not guess it. Then follow the skill's steps: decide the live side, find every use, remove, verify with `easy-post-verify.sh --grep`, and propose the commit message and Release Test Plan. Do not commit.
