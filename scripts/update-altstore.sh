#!/usr/bin/env bash
set -euo pipefail

# Regenerate altstore/apps.json from the just-synced GitLab release and commit
# it back to main, so the AltStore source always points at the newest ipa.
# Runs at the end of the github-release-sync pipeline; the commit is pushed
# with ci.skip so it does not start another pipeline.

export PATH="$HOME/.local/bin:$PATH"

RELEASE_TAG="${RELEASE_TAG:-}"
PROJECT_DIR="${CI_PROJECT_DIR:-$PWD}"

cd "$PROJECT_DIR"

if [ -z "$RELEASE_TAG" ]; then
  RELEASE_TAG=$(glab api "projects/$CI_PROJECT_ID/releases?per_page=20" | jq -r '[.[].tag_name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))][0] // empty')
fi

if ! printf '%s' "$RELEASE_TAG" | grep -qE '^v[0-9]+\.[0-9]+\.[0-9]+'; then
  echo "No versioned release to publish to the AltStore source, skipping"
  exit 0
fi
echo "Updating AltStore source for $RELEASE_TAG"

release=$(glab api "projects/$CI_PROJECT_ID/releases/$RELEASE_TAG")
ipa_url=$(printf '%s' "$release" | jq -r '[.assets.links[] | select(.name | test("ipa$")) | .direct_asset_url // .url][0] // empty')
if [ -z "$ipa_url" ]; then
  echo "No ipa asset on $RELEASE_TAG, skipping AltStore update"
  exit 0
fi

release_date=$(printf '%s' "$release" | jq -r '.released_at')
version="${RELEASE_TAG#v}"

# The release links API does not carry file sizes; HEAD the package URL.
ipa_size=$(curl -fsSLI "$ipa_url" 2>/dev/null | awk 'tolower($1)=="content-length:"{print $2}' | tr -d '\r' | tail -n1 || true)
ipa_size="${ipa_size:-0}"

min_os=$(awk '/MinimumOSVersion/{found=1} found && /<string>/{gsub(/.*<string>|<\/string>.*/,""); print; exit}' ios/Flutter/AppFrameworkInfo.plist 2>/dev/null || true)
min_os="${min_os:-13.0}"

git fetch origin main
git checkout -B main origin/main
git config user.name "GitLab CI"
git config user.email "ci@gitlab.com"

mkdir -p altstore

# Prepend the new version to any existing ones (deduped, capped at 5) so the
# source keeps a short history instead of a single entry.
existing_versions="[]"
if [ -f altstore/apps.json ]; then
  existing_versions=$(jq -c '.apps[0].versions // []' altstore/apps.json 2>/dev/null || echo "[]")
fi

new_entry=$(jq -n \
  --arg version "$version" \
  --arg date "$release_date" \
  --arg url "$ipa_url" \
  --argjson size "$ipa_size" \
  --arg minos "$min_os" \
  '{version: $version, date: $date, localizedDescription: "Latest Sketchit release.", downloadURL: $url, size: $size, minOSVersion: $minos}')

# unique_by sorts ascending, which would bury the newest entry — filter the
# old list by version instead so newest stays first.
versions=$(jq -cn --argjson new "$new_entry" --argjson old "$existing_versions" \
  '([$new] + ($old | map(select(.version != $new.version)))) | .[0:5]')

jq -n --argjson versions "$versions" '{
  name: "Sketchit",
  identifier: "com.sketchit.source",
  sourceURL: "https://gitlab.com/HttpAnimations/sketchit/-/raw/main/altstore/apps.json",
  apps: [
    {
      name: "Sketchit",
      bundleIdentifier: "com.sketchit.sketchit",
      developerName: "Sketchit",
      subtitle: "Hand-drawn whiteboard",
      localizedDescription: "A hand-drawn style whiteboard for sketching diagrams.",
      iconURL: "https://gitlab.com/HttpAnimations/sketchit/-/raw/main/assets/icon/icon.png",
      tintedIconURL: "https://gitlab.com/HttpAnimations/sketchit/-/raw/main/assets/icon/icon.png",
      category: "utilities",
      versions: $versions
    }
  ],
  news: []
}' > altstore/apps.json

git add altstore/apps.json
if git diff --cached --quiet; then
  echo "AltStore source already up to date"
  exit 0
fi

git remote set-url origin "https://oauth2:${GITLAB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git"
git commit -m "chore: 更新 AltStore 源"
git push -o ci.skip origin HEAD:main
echo "AltStore source updated for $RELEASE_TAG"
