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
- `auto-release` CI job runs on every main push: `scripts/auto-release.sh`
  does `cog bump --auto --hook-profile ci`, which updates `pubspec.yaml`
  (via `scripts/bump-version.sh`) and `CHANGELOG.md`, then pushes the bump
  commit with `ci.skip` plus the `v*` tag.
- The tag pipeline runs `build:android` (APK artifact) and `release`
  (glab uploads the APK to a GitLab release).
- `v*` tags are protected so the masked `GITLAB_TOKEN` project access
  token reaches tag pipelines. The uploads API rejects CI job tokens, so
  the release job logs glab in with that token.

## i18n

- All UI strings come from `AppLocalizations` (ARB files in `lib/l10n`,
  10 locales). Never hardcode user-facing text; add the key to every
  locale file and rerun `flutter gen-l10n`.

## Workflow

- Feature branches + merge requests; keep commits small and push often.
- Work happens on the `linux-truenas` tagged runner (shared with calc84).
