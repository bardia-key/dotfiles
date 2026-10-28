#!/usr/bin/env bash
# easy-post-verify.sh - one verification pass for an EasyPost repo.
#
# Works in the easy_post monolith (Ruby), easypost-web-backend (Python/just) and
# easypost-web-app (JS/just). It uses the repo's own Makefile/justfile targets and
# never edits files. Exit code is 1 when any check FAILs, 0 otherwise.
#
# usage: easy-post-verify.sh [--preflight] [--no-tests] [--grep REGEX]...
#   --preflight   only check the environment (gems, venv, node_modules)
#   --no-tests    run lint and the file checks, skip the touched-test run
#   --grep REGEX  fail if REGEX is still present in tracked files (cassettes excluded);
#                 use it after removing a symbol or feature flag
#
# Environment: EP_VERIFY_BASE=<ref> compares against that ref instead of origin/main|master.
#
# Written for bash 3.2 (macOS default): no associative arrays, mapfile or ${var^^}.

set -u

PREFLIGHT_ONLY=0
RUN_TESTS=1
GREPS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --preflight) PREFLIGHT_ONLY=1 ;;
    --no-tests) RUN_TESTS=0 ;;
    --grep)
      shift
      [ $# -gt 0 ] || { echo "--grep needs a pattern" >&2; exit 2; }
      GREPS+=("$1")
      ;;
    -h|--help) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not inside a git repo" >&2; exit 2; }
cd "$ROOT" || exit 2

FAILS=0
WARNS=0
pass() { printf 'PASS  %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; WARNS=$((WARNS + 1)); }
fail() { printf 'FAIL  %s\n' "$1"; FAILS=$((FAILS + 1)); }
info() { printf '      %s\n' "$1"; }
indent() { sed 's/^/      /'; }

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t epverify)
trap 'rm -rf "$TMP"' EXIT

# ---- repo, stack, base branch -------------------------------------------------
BASE=""
if [ -n "${EP_VERIFY_BASE:-}" ]; then
  BASE=$EP_VERIFY_BASE
else
  for candidate in origin/main origin/master; do
    if git rev-parse --verify -q "$candidate" >/dev/null; then BASE=$candidate; break; fi
  done
fi

STACK=generic
if [ -f Gemfile ]; then
  STACK=ruby
elif [ -f justfile ] && { [ -f pyproject.toml ] || [ -f setup.py ]; }; then
  STACK=python
elif [ -f package.json ]; then
  STACK=js
fi

BRANCH=$(git branch --show-current)
echo "repo:  $(basename "$ROOT")  ($STACK)"
echo "branch: ${BRANCH:-detached}   base: ${BASE:-none found}"
echo

case "$BRANCH" in
  main|master) warn "on the default branch ($BRANCH); work should happen on a feature branch" ;;
esac

# ---- changed files ------------------------------------------------------------
CHANGED="$TMP/changed"
DELETED="$TMP/deleted"
{
  [ -n "$BASE" ] && git diff --name-only --diff-filter=d "$BASE"...HEAD
  git diff --name-only --diff-filter=d HEAD
  git ls-files --others --exclude-standard
} 2>/dev/null | sort -u > "$CHANGED"
{
  [ -n "$BASE" ] && git diff --name-only --diff-filter=D "$BASE"...HEAD
  git diff --name-only --diff-filter=D HEAD
} 2>/dev/null | sort -u > "$DELETED"
info "$(wc -l < "$CHANGED" | tr -d ' ') changed files, $(wc -l < "$DELETED" | tr -d ' ') deleted (vs ${BASE:-HEAD}, plus working tree)"
echo

# ---- preflight ----------------------------------------------------------------
BUNDLER=bundle
[ -x vendor/bundle/bundle ] && BUNDLER=vendor/bundle/bundle

case "$STACK" in
  ruby)
    if $BUNDLER check >"$TMP/bundle_check" 2>&1; then
      pass "bundle: gems satisfied"
    else
      fail "bundle: gems missing for this branch's Gemfile.lock"
      head -3 "$TMP/bundle_check" | indent
      info "fix: $BUNDLER install (needs registry credentials, e.g. BUNDLE_DL__CLOUDSMITH__IO)"
    fi
    ;;
  python)
    if [ -x venv/bin/pytest ]; then
      pass "venv present"
    else
      fail "venv missing"
      info "fix: just _venv_requirements_installed _venv_test_requirements_installed"
      info "     (not 'just install', it drops and recreates the dev and test databases)"
    fi
    ;;
  js)
    if [ -d node_modules ]; then
      pass "node_modules present"
    else
      fail "node_modules missing"
      info "fix: just install-modules"
    fi
    ;;
esac

if [ "$PREFLIGHT_ONLY" -eq 1 ]; then
  echo
  echo "preflight done: $FAILS fail, $WARNS warn"
  [ "$FAILS" -eq 0 ]
  exit $?
fi

# ---- helpers -------------------------------------------------------------------
has_target() { # has_target <name>: does the Makefile or justfile define it?
  if [ -f Makefile ] && grep -Eq "^$1:" Makefile; then return 0; fi
  if [ -f justfile ] && grep -Eq "^$1[ :]" justfile; then return 0; fi
  return 1
}

changed_matching() { grep -E "$1" "$CHANGED" || true; }

existing_only() { # reads paths on stdin, prints the ones that exist, unique
  while IFS= read -r f; do [ -n "$f" ] && [ -f "$f" ] && echo "$f"; done | sort -u
}

# ---- lint ----------------------------------------------------------------------
echo "--- lint"
case "$STACK" in
  ruby)
    changed_matching '\.rb$' | existing_only > "$TMP/rb"
    if [ -s "$TMP/rb" ]; then
      FILES=()
      while IFS= read -r f; do FILES+=("$f"); done < "$TMP/rb"
      if $BUNDLER exec rubocop "${FILES[@]}" > "$TMP/rubocop" 2>&1; then
        pass "rubocop clean on ${#FILES[@]} changed ruby files"
      else
        fail "rubocop reports offenses (CI lints whole changed files, so old offenses count too)"
        grep -E '^[^ ].*:[0-9]+:[0-9]+: [CWEF]:|inspected' "$TMP/rubocop" | head -30 | indent
      fi
    else
      pass "no ruby files changed, rubocop skipped"
    fi
    ;;
  python|js)
    if has_target lint; then
      if just lint > "$TMP/lint" 2>&1; then
        pass "just lint"
      else
        fail "just lint"
        grep -Ei 'error|would reformat|fail' "$TMP/lint" | head -15 | indent
      fi
    else
      warn "no lint target found; check the justfile/Makefile"
    fi
    ;;
  *) warn "unknown stack, lint skipped" ;;
esac
echo

# ---- touched tests ----------------------------------------------------------------
if [ "$RUN_TESTS" -eq 1 ]; then
  echo "--- tests for touched files"
  : > "$TMP/tests"
  case "$STACK" in
    ruby)
      {
        changed_matching '^spec/.*_spec\.rb$'
        changed_matching '^app/.*\.rb$' | sed -E 's#^app/(.*)\.rb$#spec/\1_spec.rb#'
        changed_matching '^lib/.*\.rb$' | sed -E 's#^lib/(.*)\.rb$#spec/lib/\1_spec.rb#'
      } | existing_only > "$TMP/tests"
      ;;
    python)
      {
        changed_matching '^tests/.*test_.*\.py$'
        changed_matching '^api/.*\.py$' | sed -E 's#^api/(.*/)?([^/]+)\.py$#tests/\1test_\2.py#'
      } | existing_only > "$TMP/tests"
      ;;
    js)
      {
        changed_matching '\.test\.(ts|tsx|js|jsx)$'
        changed_matching '\.(ts|tsx|js|jsx)$' | grep -Ev '\.test\.' | sed -E 's#\.(ts|tsx|js|jsx)$#.test.\1#'
      } | existing_only > "$TMP/tests"
      ;;
  esac

  if [ ! -s "$TMP/tests" ]; then
    warn "no touched tests found; consider running the broader suite (make test / just test)"
  else
    TESTS=()
    while IFS= read -r f; do TESTS+=("$f"); done < "$TMP/tests"
    info "${#TESTS[@]} test files: ${TESTS[*]}"
    case "$STACK" in
      ruby)
        if has_target test; then
          make test TARGET="${TESTS[*]}" > "$TMP/test_out" 2>&1
        else
          $BUNDLER exec rspec "${TESTS[@]}" > "$TMP/test_out" 2>&1
        fi
        ;;
      python)
        : > "$TMP/test_out"
        for t in "${TESTS[@]}"; do just test "$t" >> "$TMP/test_out" 2>&1; done
        ;;
      js)
        just test "${TESTS[@]}" > "$TMP/test_out" 2>&1
        ;;
    esac

    if grep -q 'PendingMigrationError' "$TMP/test_out"; then
      fail "test database has pending migrations"
      info "fix: make test-db"
    elif grep -Eq '[0-9]+ examples?, 0 failures|[0-9]+ passed|Tests: +[0-9]+ passed' "$TMP/test_out" \
      && ! grep -Eq '[1-9][0-9]* failures?|[1-9][0-9]* failed|error occurred outside' "$TMP/test_out"; then
      pass "$(grep -E '[0-9]+ examples?, |[0-9]+ passed|Tests: ' "$TMP/test_out" | tail -1 | sed -E 's/^[= ]+//; s/[= ]+$//')"
    else
      fail "touched tests failed or did not run"
      grep -E 'examples?, |^rspec |FAILED|failed|Error' "$TMP/test_out" | head -20 | indent
    fi
  fi
  echo
fi

# ---- cassettes ----------------------------------------------------------------------
for dir in spec/cassettes tests/cassettes; do
  [ -d "$dir" ] || continue
  echo "--- cassettes ($dir)"
  NEW=$(git ls-files --others --exclude-standard "$dir" | wc -l | tr -d ' ')
  GONE=$(grep -c "^$dir/" "$DELETED" || true)
  if [ "$NEW" -gt 0 ]; then
    warn "$NEW new untracked cassette files; delete any recorded by accident, they cannot be re-recorded offline"
    git ls-files --others --exclude-standard "$dir" | head -5 | indent
  else
    pass "no untracked cassette files"
  fi
  if [ "$GONE" -gt 0 ]; then
    info "$GONE cassette files deleted or renamed; make sure each belongs to a removed or renamed example"
  fi
  echo
done

# ---- lockfiles ------------------------------------------------------------------------
LOCKS=$(git diff --name-only HEAD 2>/dev/null | grep -E '(^|/)(Gemfile\.lock|package-lock\.json|.*\.lock)$' || true)
if [ -n "$LOCKS" ]; then
  warn "uncommitted lockfile change; intended?"
  echo "$LOCKS" | indent
fi

# ---- leftovers -------------------------------------------------------------------------
if [ "${#GREPS[@]}" -gt 0 ]; then
  echo "--- leftovers"
  for pattern in "${GREPS[@]}"; do
    HITS=$(git grep -n -E "$pattern" -- . ':!spec/cassettes' ':!tests/cassettes' 2>/dev/null || true)
    if [ -z "$HITS" ]; then
      pass "no tracked references to: $pattern"
    else
      fail "$(echo "$HITS" | wc -l | tr -d ' ') tracked references to: $pattern"
      echo "$HITS" | head -10 | indent
    fi
  done
  echo
fi

echo "result: $FAILS fail, $WARNS warn"
[ "$FAILS" -eq 0 ]
