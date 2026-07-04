---
name: release-apk
description: Use when cutting a new app release or deploying a new version.
  Builds a signed release APK locally and publishes a GitHub Release with it.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: release
---

# Release APK (Local Build + GitHub Release)

Cut a new version: bump version, build a signed APK locally, publish a GitHub
Release. Faster than the CI release workflow (~2-3 min vs ~8 min) and the in-app
updater consumes only the APK asset.

## When to Use

- Releasing / deploying a new app version.
- User says "배포", "릴리스", "release", "deploy", "출시", "배포해줘".

## When NOT to Use

- Regular feature work / commits (just `git push`).
- Play Store release (needs AAB — not covered; this flow is APK-only).

## Prerequisites (verify first)

- `flutter doctor` → Android toolchain ✓
- `android/app/release.keystore` + `android/key.properties` exist (release signing)
- `gh auth status` logged in
- `git status` clean (no uncommitted work)

## Protocol

### 1. Pre-check
- `git status -sb` — working tree clean.
- `make check` (analyze + test) — MUST pass.

### 2. Determine version
- Current: `grep '^version:' pubspec.yaml` → e.g. `1.6.1+9`.
- Pick next with the user; increment the build number (`+N`) every release:
  - fixes → patch: `1.6.1+9` → `1.6.2+10`
  - features → minor: → `1.7.0+10`
  - breaking → major: → `2.0.0+10`
- Scan `git log <lastTag>..HEAD --oneline` to decide (features→minor, fixes→patch).

### 3. Bump + commit + push
- Edit `pubspec.yaml` `version:` line.
- `git add pubspec.yaml && git commit -m "chore: bump version to X.Y.Z+N"`
- `git push origin master` (CI `ci.yml` runs analyze+test as a safety net).

### 4. Build signed APK
- `flutter build apk --release`
- Output: `build/app/outputs/flutter-apk/app-release.apk` (signed via `key.properties`).

### 5. Publish GitHub Release
- `gh release create vX.Y.Z build/app/outputs/flutter-apk/app-release.apk --generate-notes --notes "Release vX.Y.Z — <short summary>"`
  - Creates tag + release + uploads APK in one step.
  - Tag is `vX.Y.Z` (NO build number — matches the last released version `v1.x` convention).

### 6. Verify
- `gh release view vX.Y.Z` — confirm the `app-release.apk` asset is present.
- The in-app updater will now offer this version to older builds.

## Common Mistakes

- Forgetting the version bump/commit before building.
- Pushing the build before `git push` (skips the CI safety net).
- Including `.aab` — not needed (the updater fetches `.apk` only).
- Tag `vX.Y.Z` vs pubspec `X.Y.Z+N`: the tag has NO build number.
- Releasing with a dirty tree or while `make check` fails.

## Notes

- CI `release.yml` is `workflow_dispatch` (manual) — local build is the default; run the workflow by hand only as a fallback.
- AAB is intentionally skipped (GitHub-based distribution; Play Store not in use).
- The release APK is signed with the same keystore CI uses, so existing installs accept the update.
