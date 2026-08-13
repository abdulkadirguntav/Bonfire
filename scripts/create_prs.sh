#!/usr/bin/env bash
set -e
if [ -z "$GITHUB_TOKEN" ]; then echo "ERROR: GITHUB_TOKEN not set"; exit 1; fi
url=$(git remote get-url origin 2>/dev/null || true)
# Support both git@github.com:owner/repo.git and https://github.com/owner/repo.git
owner_repo=""
if [ -n "$url" ]; then
  owner_repo=${url#git@github.com:}
  owner_repo=${owner_repo#https://github.com/}
  owner_repo=${owner_repo%.git}
fi
if [ -z "$owner_repo" ]; then echo "ERROR: cannot determine owner/repo (remote URL: $url)"; exit 1; fi
echo "Repo: $owner_repo"
branches=$(git branch --list "feature/*" | sed "s/^[ *]*//")
if [ -z "$branches" ]; then echo "No feature branches found"; exit 0; fi
for b in $branches; do
  echo "---"
  echo "Processing $b..."
  payload=$(jq -n --arg t "PR: $b -> dev" --arg head "$b" --arg base "dev" --arg body "Merge $b into dev (feature PR). Do not merge to main." '{title:$t, head:$head, base:$base, body:$body}')
  resp=$(curl -s -S -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" -d "$payload" "https://api.github.com/repos/$owner_repo/pulls") || true
  html=$(echo "$resp" | jq -r .html_url)
  if [ "$html" != "null" ] && [ -n "$html" ]; then
    echo "Created: $html"
  else
    msg=$(echo "$resp" | jq -r .message)
    if echo "$msg" | grep -qi "A pull request already exists"; then
      echo "PR already exists — querying existing PR..."
      existing=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$owner_repo/pulls?head=$(echo $owner_repo | cut -d/ -f1):$b&base=dev") || true
      exurl=$(echo "$existing" | jq -r '.[0].html_url')
      echo "Already exists: $exurl"
    else
      echo "Failed to create PR for $b. Response: $(echo "$resp" | jq -c .)"
    fi
  fi
  sleep 0.5
done
