---
name: ruby-makefile-test
description: Run Ruby tests via Makefile with TARGET parameter
license: MIT
compatibility: opencode
metadata:
  audience: ruby-developers
  workflow: testing
---

## What I do

I help you run specific Ruby tests in repositories that use Makefile-based test workflows. I recognize when a Ruby project has a Makefile with a test target that accepts a `TARGET` parameter.

## When to use me

Use this skill when:
- You're in a Ruby repository (has Gemfile, spec/ or test/ directory)
- The repository has a Makefile with a test target
- You need to run specific tests during development
- The user asks to run tests, specs, or test files

## How to run tests

Use the following command format:

```bash
make test TARGET=/path/to/spec_file.rb:<line-number>
```

### Examples

Run a specific spec file:
```bash
make test TARGET=spec/models/user_spec.rb
```

Run a specific test at a line number:
```bash
make test TARGET=spec/models/user_spec.rb:42
```

Run multiple specs (if supported):
```bash
make test TARGET="spec/models/user_spec.rb spec/services/auth_spec.rb"
```

## Workflow tips

1. **Always verify the Makefile exists** before suggesting this approach
2. **Check for the test target** in the Makefile to confirm it accepts TARGET
3. **Provide the full path** from the repository root
4. **Include line numbers** when the user wants to run a specific test/context
5. **Suggest reading Makefile** if uncertain about supported parameters

## Fallback options

If the Makefile doesn't support TARGET parameter, suggest alternatives:
- `bundle exec rspec <path>:<line>`
- `bundle exec rake test`
- `rake test TEST=<path>`
- Check the Makefile for other test-related targets
