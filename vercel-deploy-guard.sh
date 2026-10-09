#!/usr/bin/env bash
# Vercel deploy-guard — Claude Code PreToolUse hook (Bash matcher).
# Reads the hook JSON on stdin, emits a PreToolUse permissionDecision JSON.
#
# Three outcomes for a `vercel` command:
#   1. --prod / --production / promote           -> ASK  (red: éles deploy)
#   2. deploy-capable in an UNLINKED dir          -> ASK  (orange: első deploy = prod)
#      (bare `vercel` or `vercel deploy`, and no .vercel/project.json present)
#   3. anything else vercel (dev/ls/env/git/...)  -> ALLOW
# Non-vercel commands: pass through silently (exit 0, no output).

cmd="$(jq -r '.tool_input.command // ""')"

# Not a vercel invocation? let it through untouched.
printf '%s' "$cmd" | grep -Eq '(^|[^[:alnum:]_/])(npx +)?vercel([[:space:]]|$)' || exit 0

emit() { # $1 = decision (ask|allow), $2 = reason text
  jq -nc --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
}

# --- 1) Explicit production deploy / promote -> always ASK (red) -------------
if printf '%s' "$cmd" | grep -Eqi -- '(--prod\b|--prod=|--production\b|vercel +promote\b)'; then
  emit ask "$(printf '🔴🚨  ÉLES (PRODUCTION) VERCEL DEPLOY  🚨🔴\n\n⚠️  Ez a parancs ÉLESRE tölt fel — a változás AZONNAL látható a production URL-en.\n⚠️  Csak akkor hagyd jóvá, ha tényleg élesíteni akarsz!\n\nParancs:\n%s' "$cmd")"
  exit 0
fi

# --- Is this a deploy-capable invocation? -----------------------------------
# First non-flag word after `vercel`: empty (bare vercel) or "deploy" => deploy.
# Anything else (dev, ls, env, git, inspect, logs, link, whoami, pull, ...) is
# not a fresh deploy, so it can't silently go to production.
after="$(printf '%s' "$cmd" | sed -E 's/.*(^|[^[:alnum:]_/])(npx +)?vercel[[:space:]]*//')"
firstword="$(printf '%s' "$after" | awk '{for(i=1;i<=NF;i++){if($i !~ /^-/){print $i; exit}}}')"

if [ -z "$firstword" ] || [ "$firstword" = "deploy" ]; then
  # --- Resolve the target directory --------------------------------------
  # priority: `vercel --cwd <dir>`  >  leading `cd <dir> && ...`  >  $PWD
  target_dir="$PWD"
  cwd_flag="$(printf '%s' "$cmd" | sed -nE 's/.*--cwd[ =]+([^ &;|]+).*/\1/p' | tr -d "\"'")"
  if [ -n "$cwd_flag" ]; then
    target_dir="$cwd_flag"
  elif printf '%s' "$cmd" | grep -Eq '^[[:space:]]*cd[[:space:]]'; then
    cd_dir="$(printf '%s' "$cmd" | sed -E 's/^[[:space:]]*cd[[:space:]]+//; s/[[:space:]]*(&&|;|\|).*$//' | tr -d "\"'")"
    [ -n "$cd_dir" ] && target_dir="$cd_dir"
  fi

  # --- 2) Deploy-capable + UNLINKED -> ASK (orange) ----------------------
  if [ ! -f "$target_dir/.vercel/project.json" ]; then
    emit ask "$(printf '🟠⚠️  LINKELETLEN VERCEL PROJEKT — ELSŐ DEPLOY = PRODUCTION!  ⚠️🟠\n\nEbben a mappában nincs .vercel/project.json, tehát a projekt még NINCS linkelve.\nEgy linkeletlen projekt ELSŐ `vercel deploy`-ja EGYENESEN ÉLESRE (production) megy\nés ráteszi a fő domaint — akkor is, ha NEM adtál meg --prod kapcsolót.\n\nMappa: %s\nParancs:\n%s\n\nCsak akkor hagyd jóvá, ha tudod, hogy ez élesre fog menni.' "$target_dir" "$cmd")"
    exit 0
  fi
fi

# --- 3) Everything else (linked deploy, dev, ls, env, git, ...) -> ALLOW -----
emit allow "Vercel (nem éles, linkelt) parancs — automatikusan engedélyezve."
