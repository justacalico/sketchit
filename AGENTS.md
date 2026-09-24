# Sketchit

Flutter whiteboard app (Android/iOS/Linux/macOS/Windows/web). Repo lives at
https://gitlab.com/HttpAnimations/sketchit, GitLab Pages serves the web build.

## Commands

- `flutter pub get` then `flutter analyze`, `flutter test`
- `flutter build web --release --base-href "/"` (Pages uses the unique domain)
- Local disk quota is tight: prefix builds with `TMPDIR=$HOME/tmp` if /tmp fails

## Versioning and releases

- cocogitto (`cog.toml`) drives versioning. Commits must use conventional
  prefixes (`feat:`, `fix:`, `perf:`, `chore:`...) or `cog bump` will not
  produce a new version. Keep the Chinese subject after the prefix,
  e.g. `fix: release 任务缺少 git`.
- Builds run on GitHub Actions at the `justacalico/sketchit` mirror.
  `github-sync` pushes main/tag updates to GitHub and watches the run;
  `github-mr-build` dispatches a build for MR source branches;
  `github-dispatch` does the same for web-triggered pipelines.
- `auto-release` CI job runs on every main push (after `github-sync`):
  `scripts/auto-release.sh` does `cog bump --auto --hook-profile ci`,
  which updates `pubspec.yaml` (via `scripts/bump-version.sh`) and
  `CHANGELOG.md`, then pushes the bump commit with `ci.skip` plus the
  `v*` tag.
- The GitHub workflow builds every platform (android apk/aab, linux
  tar.gz/zip/deb/rpm/AppImage x86_64+arm64, windows zip x86_64+arm64,
  macOS dmg/zip, unsigned iOS ipa, web tarball) and publishes `nightly`
  on main pushes and versioned releases on `v*` tags. Its `gitlab-sync`
  job then triggers `github-release-sync` back on GitLab, which mirrors
  the release into the package registry so binaries never expire, runs
  `scripts/update-altstore.sh` for versioned releases, and deploys Pages
  (web build + `altstore/`).
- `v*` tags are protected so the masked `GITLAB_TOKEN` project access
  token reaches tag pipelines; the `GitHub release sync` deploy key may
  also create them. `GITLAB_TOKEN` is likewise used to push the bump and
  AltStore commits to protected main.
- AltStore source lives at `altstore/apps.json` and is served at
  `https://sketchit-546a9a.gitlab.io/altstore/apps.json`.

## i18n

- All UI strings come from `AppLocalizations` (ARB files in `lib/l10n`,
  10 locales). Never hardcode user-facing text; add the key to every
  locale file and rerun `flutter gen-l10n`.

## Workflow

- Feature branches + merge requests; keep commits small and push often.
- Work happens on the `linux-truenas` tagged runner (shared with calc84).
