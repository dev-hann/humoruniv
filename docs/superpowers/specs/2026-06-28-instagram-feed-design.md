# Design: Instagram-style Feed (웃긴자료 Home)

- **Date**: 2026-06-28
- **Status**: Implemented & GREEN — `make check` passes (666 tests, 0 errors). See "Build Outcome" below.
- **Scope**: Phase 1 read-only, 웃긴자료 (pds) board only

## Build Outcome (2026-06-28)

**Implemented (TDD, all GREEN):**
- `BoardPost` entity extended with optional `previewText` / `isNsfw` (Step 1).
- New widgets: `FeedMedia` (atom), `TextPostCard` (molecule), `FeedCard` (molecule), `SkeletonFeedCard` (state), `FeedList` (organism). `BottomNavBar` → 3 destinations.
- `HomeScreen` rewritten → Instagram-style feed via `FeedList` + `boardPostsProvider`. `MainTabsScreen` → 3 tabs (홈/검색/설정).
- `feedMediaHeight` token added. `PRODUCT_PLAN.md` §4 IA updated.

**Parser spike result:** the list HTML exposes **neither** `previewText` nor an NSFW flag (no body snippet; no adult/19+ marker — `style_type1/2/3` are author level colors). So feed cards are title-driven; per-item NSFW blur is deferred to the detail screen (which already guards it).

**Steps collapsed (no code needed):** DTO (Step 3, YAGNI — no producer of the new fields), DataSource/Repo/UseCase (Step 4), DI (Step 5), Provider (Step 6) — the existing `boardPostsProvider` already defaults to `table:'pds', sort:SortOption.all` with pagination, so it IS the feed provider.

**Deferred (follow-up):**
- ~~Retire now-unused widgets~~ — DONE: deleted `presentation/widgets/post_card.dart`, `molecules/post_card.dart`, `molecules/hero_card.dart`, `organisms/home_feed.dart`, `organisms/post_list.dart` (+ their tests). `board_post_card.dart` + `BoardScreen` kept (Phase 3 reuse).
- ~~E2E test~~ — DONE: `integration_test/app_e2e_test.dart` rewritten for the new arch (`boardPostsProvider` override via fake `BoardPostsNotifier`, `BoardPost`, `FeedCard`). Needs `make e2e` (device) to execute. `app_smoke_test.dart` finders updated (`ListTile`→`FeedCard`, current Korean state texts).
- ~~PRODUCT_PLAN §5 / §7~~ — DONE: Screen Map + Flows updated (board tab/flow → Phase 3; hero removed).
- Best-filter re-introduction (top-bar icon → bottom sheet) if Casual/Newcomer curation becomes a priority — still deferred by user decision (pure chronological).

## 1. Overview

Transform the app's main experience from a community card-list into a single
Instagram-style vertical media feed. The current 4 tabs
(홈 종합베스트 / 게시판 웃긴자료 / 검색 / 설정) collapse to **3 tabs**
(홈 피드 / 검색 / 설정). The old Home(종합베스트) and Board(웃긴자료) tabs
merge into one Home feed showing 웃긴자료 posts. Single chronological feed,
no filters. Phase 1 is read-only (counts displayed, no recommend action).

### Locked product decisions

1. **Scope**: 웃긴자료 (pds) board only. Home = unified Instagram-style feed.
   Other boards excluded until Phase 3.
2. **Tabs**: 3 tabs — 홈(웃긴자료 피드) / 검색 / 설정. Board tab removed.
3. **Feed item exposure**: inline preview — author header + large media OR
   brand-color typography card + caption (title + optional preview) + counts.
   Tap → PostDetailScreen (full body + comments).
4. **Media posts**: full-bleed large image (edge-to-edge).
5. **Text-only posts**: brand-color (primary) background + large typography
   card where the text itself is the visual. Instagram-native treatment of text.
6. **No sort/filter UI**: single chronological (latest-first) feed.
7. **Infinite scroll** + **pull-to-refresh** retained.
8. **Phase 1 read-only**: counts display-only. Recommend action is Phase 2.
9. **Old 종합베스트 / "오늘의 1위" hero** is dropped in favor of a flat
   chronological feed.
10. **Timestamp placement**: Instagram-style — at the **bottom** of the card
    (under the caption), NOT in the header. Header = avatar + nickname + optional
    badge only.

### Instagram-fidelity audit

The feed follows the Instagram Home feed pattern (single column, header →
full-bleed media → action row → caption, thin separators, no filters).
Intentional deviations, all driven by data reality:

| Instagram | This design | Reason |
|-----------|-------------|--------|
| Stories row at top | absent | 웃긴자료 has no stories concept; no data to fill the slot |
| Actions ❤️ 💬 ✈️ … 🔖 | 👍 💬 👁 (display-only) | source exposes recommend/view/comment, not like/share; read-only in Phase 1 |
| Timestamp at bottom | **bottom** (aligned) | — |
| Comment preview under caption | absent | list API has no comment data |
| Multi-image carousel | first image + `+N` badge | Phase 1 simplification; gallery exists in detail |
| No text feed posts | brand-color typography card | text-heavy community; borrows Instagram story text-background idiom |

## 2. Information Architecture (changes)

- Bottom tabs: 4 → **3**.
  - 홈 (`home` icon) → AppBar title **"웃긴자료"** (content-name, not generic "홈").
  - 검색 (`search` icon).
  - 설정 (`settings` icon).
  - **게시판 tab removed.**
- Routes unchanged: `/` (MainTabs), `/post?url=` (PostDetail). Tab switch by index.
- `PRODUCT_PLAN.md` §4 (IA), §5 (Screen Map), §7 (Flows 1/2/3) must be updated
  in the same change set. Flow 3 (Board Exploration) disappears; Flow 2 loses
  the hero card.

## 3. Data Layer

- **Entity**: unify on `BoardPost` (richest existing entity). Extend with two
  **optional** fields:
  - `previewText` (String?) — populated only if a parser spike confirms the
    list HTML exposes a snippet; otherwise `null` and the card omits it.
  - `isNsfw` (bool, default `false`) — populated only if the list HTML exposes
    an NSFW flag; otherwise `false`. (Detail screen still guards via its own
    `isNsfw`.)
  - The old `Post` entity, `bestPostsProvider`, and `GetBestPosts` usecase are
    **unwired from the UI** (code preserved, not deleted — may be reused for a
    future best toggle).
- **Provider**: repurpose the existing paginated `boardPostsProvider` as
  `feedProvider`. Parameters fixed: `table = pds`, `sort = latest` (전체).
  Pagination state preserved (`posts`, `currentPage`, `totalPage`,
  `isLoadingMore`, `loadMoreError`, `hasMore`).
- **UseCase / Repository / DataSource**: reuse the existing `GetBoardPosts`
  path. **No new usecase, no extra network calls** — the feed still issues one
  list request per page (the 2s rate limit is respected).

## 4. Presentation / Widgets

New Instagram-specific widgets (fresh build; reuse atoms). Atomic Design tiers
per DESIGN.md.

| Widget | Tier | Responsibility |
|--------|------|----------------|
| `FeedMedia` | atom (new) | Full-bleed media. States: `loading` (shimmer) / `loaded` / `error` / `nsfw-blurred` / `multi-image` (+N badge). `BoxFit.contain` up to `feedMediaMaxHeight`, then `BoxFit.cover` (center crop). No radius. Tap → ImageViewerScreen (shared element). |
| `TextPostCard` | molecule (new) | Text-only posts. `colorScheme.primary` background + `headlineSmall` title + `bodyLarge` secondary line. Text color **`colorScheme.onPrimary`** (token-driven, never hardcoded white). |
| `FeedCard` | molecule (new) | Composes header (avatar + nick + optional badge) + body (`FeedMedia` or `TextPostCard`) + action row (👍/💬/👁, display-only, 44pt targets) + caption (title + optional preview) + **timestamp (bottom)**. Wrapped in a `Material(color: surfaceContainer)` card surface with a 12dp inter-card gap; no border/radius/divider (media stays full-bleed square). |
| `SkeletonFeedCard` | state (new) | Shimmer mirroring `FeedCard` shape (header row + full-width media block + action row + 2 caption lines). |
| `HomeFeed` | organism (rewrite) | Renders `FeedCard`s with pagination + all states (loading → `SkeletonFeedCard`, empty → `EmptyStateView`, error → `ErrorStateView`, offline → `StaleDataBanner`). |
| `BottomNavBar` | organism (edit) | Make `destinations` a constructor parameter; pass 3. |

**Retired (stop using):**
- Live: `lib/presentation/widgets/post_card.dart`, `board_post_card.dart`.
- Designed-but-unused: `lib/core/widgets/molecules/post_card.dart`,
  `hero_card.dart`, `lib/core/widgets/organisms/post_list.dart`.

**Screens:**
- `HomeScreen` rewritten to watch `feedProvider` and render `HomeFeed`.
- `MainTabsScreen` → 3 tabs.
- `BoardScreen` removed from tabs (file preserved for Phase 3 multi-board).
- `PostDetailScreen`, `ImageViewerScreen` reused unchanged.

## 5. States (all committed)

- **First load**: `SkeletonFeedCard` list (shimmer).
- **Pagination**: inline skeleton/spinner at bottom; no scroll-position jump.
  Trigger: when the **2nd-from-last card** enters the viewport (the cards are
  tall, so the old 80% rule triggers too early).
- **Empty**: `EmptyStateView` ("게시글이 없어요" + retry).
- **Error**: `ErrorStateView` + retry (network or parse failure).
- **Offline**: cached feed + `StaleDataBanner` ("마지막 업데이트 N분 전").
- **Pull-to-refresh**: yes.

## 6. Interaction / Motion

- Card tap → `PostDetailScreen` (platform-default transition).
- Image tap → `ImageViewerScreen` (shared-element transition).
- Text-only card tap → `PostDetailScreen` (platform-default; no hero image).
- **NSFW in feed**: no per-item blur in Phase 1 (list data lacks the flag).
  Guarded by first-launch warning dialog + detail-screen blur. Add feed blur
  later if the parser spike surfaces an NSFW flag from list HTML.
- **Read-state**: dimmed title + small "읽음" dot; media/typography untouched.
- Motion tokens: `AppDurations.medium` (300ms) + `AppCurves.standard`.

## 7. Design Tokens

**New tokens** (add to `lib/core/themes/`):

| Token | Value | File |
|-------|-------|------|
| `feedMediaMaxHeight` | `0.66 × screenHeight`, floor 420, cap 600 | `app_sizes.dart` |

**Reused / existing tokens:**

| Concern | Token |
|---------|-------|
| Card surface | `colorScheme.surfaceContainer` (tonal contrast vs scaffold; both modes) |
| Card elevation | `AppElevation.level1` (light) / `level0` tonal-only (dark) |
| Inter-card gap | `AppSpacing.p12` (12dp); no divider line |
| Text card background | `colorScheme.primary` |
| Text card text | `colorScheme.onPrimary` (dark across all 6 schemes; never white) |
| Text card title | `headlineSmall` (20pt / w600 / h1.35, max 3 lines) |
| Text card secondary | `bodyLarge` (16pt / w400 / h1.6, max 2 lines) |
| Media caption title | `titleMedium` (16pt / w600) |
| Media caption preview | `bodyMedium` (14pt / w400) |
| Action row counts | `labelSmall` |
| Action row icons | `iconLarge` (24), 44pt touch targets, `p8` gaps, `edgeH16` padding |
| Avatar | `avatarSmall` (32pt) |
| Timestamp | `labelSmall`, `onSurfaceVariant` |

**WCAG note**: white-on-orange measures 2.82:1 (light) / 2.26:1 (dark) — below
even the 3.0:1 large-text threshold. The text card MUST use `colorScheme.onPrimary`
(computed dark by `flex_color_scheme` for all 6 brand schemes). Hardcoded white
is prohibited.

## 8. Testing (TDD — per AGENTS.md tiers)

- **Parser (Tier S)**: per-case tests for `previewText` / `isNsfw` extraction —
  only after the parser spike confirms the list HTML exposes them.
- **DTO (Tier B)**: `toEntity()` for the extended `BoardPost`.
- **DataSource / Repository / UseCase (Tier A)**: light tests for the fixed
  `table=pds / sort=latest` params (mostly reuse).
- **Provider (Tier A)**: `feedProvider` pagination + all states.
- **Widgets (Tier A)**: `FeedMedia` (all 5 states), `FeedCard`, `TextPostCard`,
  `SkeletonFeedCard`, `HomeFeed` (states), `BottomNavBar` (3 destinations).
- **Widget / integration**: `HomeScreen` renders the feed end-to-end.

## 9. Scope cuts / Future

- No best filter / toggle (PM concern documented; re-add via top-bar icon →
  bottom sheet when Casual/Newcomer curation becomes a priority).
- No per-item NSFW blur in feed (until list exposes the flag).
- No carousel (first image + `+N` badge only).
- No stories row.
- `previewText` optional (pending parser spike).
- Phase 3: multi-board reuses the preserved `BoardScreen` flow.

## 10. Implementation Strategy

- **Entity**: extend `BoardPost` (do not create a new entity) — reuses tested
  pagination. *(Alternative rejected: new `FeedItem` — duplicates fields and
  test surface.)*
- **Widgets**: fresh Instagram widgets, reuse atoms — existing widgets do not
  match the layout. *(Alternative rejected: adapt the unused organisms — more
  work than rebuilding.)*
- **Provider**: repurpose `boardPostsProvider` → `feedProvider`.
- **Docs**: update `PRODUCT_PLAN.md` §4 / §5 / §7 in the same change set.

## 11. TDD Step Order (AGENTS "Adding a New Feature" checklist)

1. Domain: extend `BoardPost` entity (+ tests).
2. Parser spike: confirm whether list HTML exposes `previewText` / `isNsfw`.
   If yes → per-case parser tests (Tier S) then extraction code.
3. DTO: extend `BoardPostDto.toEntity()` (+ tests).
4. DataSource / Repository / UseCase: fix params, light tests (Tier A).
5. DI: register `feedProvider` (replaces `boardPostsProvider` wiring).
6. Provider: `feedProvider` pagination + states (Tier A).
7. Widgets: `FeedMedia` → `TextPostCard` → `FeedCard` → `SkeletonFeedCard`
   → `HomeFeed` → `BottomNavBar` (each Tier A).
8. Screen: rewrite `HomeScreen`, update `MainTabsScreen` (3 tabs).
9. Integration test: real layers wired.
10. E2E test: scroll → card → detail → back.
11. Docs: update `PRODUCT_PLAN.md` §4 / §5 / §7.
12. Final: `make check` (analyze + test, zero errors) before commit.

## 12. Open Questions Resolved (feature-consensus)

All PM/Designer objections resolved with defaults (preview-text data source,
NSFW in feed, read-state, five feed states, pagination trigger, WCAG contrast,
aspect-ratio policy, new `FeedMedia` atom, `SkeletonFeedCard`, token mapping,
docs update). The one product fork — adding a best toggle for Casual/Newcomer
personas — was declined by the user in favor of pure chronological feed
(documented as a future option).
