---
description: Assess review feedback (Copilot or human) and propose a verdict, options and a reply
---

Load the `review-feedback-triage` skill and assess this review feedback: $ARGUMENTS

If it is a PR URL or number, read the comments with `gh pr view <pr> --comments` and `gh pr diff <pr>`. Verify the mechanism in the code and the framework version in use, decide whether it is a regression or pre-existing, and give options with a recommendation, a test strategy and a draft reply. Do not change code or post anything until I choose an option.
