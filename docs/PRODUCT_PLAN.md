# Product Plan

## 1. Project Definition

Unofficial native mobile app for [humoruniv.com](https://m.humoruniv.com), a Korean humor community since 1998.

- No backend server. The app fetches HTML from `m.humoruniv.com`, decodes EUC-KR, parses the DOM, and presents structured data.
- Clean Architecture: Presentation / Domain / Data layers with strict dependency direction.
- TDD-first development. All features require unit, widget, integration, and E2E tests.

### Core Constraint: Single Board Focus

The app focuses exclusively on **웃긴자료 (pds)** — the main humor board — until Phase 3.

Rationale:
- Reduces parser surface area from 30+ board layouts to 1.
- Dramatically lowers maintenance risk (1 parser to update vs 30+).
- Faster time to MVP: 1.5-2 weeks instead of 3-4.
- The pds board is the highest-traffic, highest-value board on the site.
- Most other boards share the same HTML template, so adding them later requires minimal new parser code.

## 2. Target Users (Personas)

### Casual Viewer

- **Behavior**: Commute, spare time. Consumes best posts.
- **Core Need**: Fast scroll through top content.
- **Scenario**: Opens app on subway. Sees today's hero post immediately. Scrolls through best 25. Closes app after 5 minutes. No login needed.
- **Frequency**: 2-3 times per week.

### Regular

- **Behavior**: Visits daily. Reads broadly.
- **Core Need**: Full post list with filters.
- **Scenario**: Opens app during lunch break. Checks recent tab first, then switches to weekly best filter. Reads 10-15 posts including comments. Occasionally bookmarks.
- **Frequency**: Daily.

### Active User

- **Behavior**: Comments, recommends, participates.
- **Core Need**: Login, interactions.
- **Scenario**: Logs in first thing. Checks responses to their comments. Recommends posts they enjoy. Writes comments on hot topics. Checks scrap list.
- **Frequency**: Multiple times daily.

### Newcomer

- **Behavior**: First visit. Doesn't know the site.
- **Core Need**: Curated best content, low barrier.
- **Scenario**: Heard about the app from a friend. Opens it and sees curated best content immediately. No login, no setup needed. Browses popular posts to understand the community.
- **Frequency**: First few visits, may convert to Casual or Regular.

## 3. UX Principles

1. **3-second content access**: First meaningful content visible within 3 seconds of app launch. Cached data shown instantly, fresh data loads in background.
2. **Zero-friction browsing**: Scroll through home feed without extra taps. No forced onboarding, no login wall. Content is always one tap away.
3. **Visual content priority**: Posts with images are emphasized in the feed. Image viewing is fullscreen, swipeable, and requires no extra navigation.
4. **Seamless navigation**: Screen transitions, back navigation, and deep links work naturally. Users never feel "lost" in the app.
5. **Offline resilience**: Cached content available when disconnected. Never show a blank screen. Clearly indicate stale data with timestamp.
6. **Korean-first UX**: Korean typography, reading direction, content density optimized for Korean community content. No Western-centric assumptions.

## 4. Information Architecture

4 bottom tabs:

```
┌──────────┬──────────┬──────────┬──────────┐
│   Home   │  Recent  │  Search  │ Settings │
│ (House)  │ (Clock)  │ (Search) │ (Gear)   │
│  Best    │  All     │  PDS     │          │
└──────────┴──────────┴──────────┴──────────┘
```

### Home Tab (Best Posts)

- Hero card: today's #1 post with thumbnail, title, recommend count.
- Best posts list: top 25 by recommend count.
- Pull-to-refresh.
- Read posts shown in muted color.
- Cached data shown when offline.

### Recent Tab (All Posts)

- All posts in chronological order.
- Filter tabs: daily best / weekly best / monthly / yearly / recommend 500+.
- Infinite scroll with pagination.
- Pull-to-refresh.
- Write button (FAB) when logged in (Phase 3).

### Search Tab

- Search bar with debounce.
- Period filter: 1 day / 1 week / 1 month / 6 months / 1 year / all.
- Search history (stored locally).
- Results shown as post cards.

### Settings Tab

- Login / logout status.
- Scrap list.
- Read history.
- Favorite boards management (for future Phase 3 expansion).
- Dark mode toggle (system-aware).
- Font size adjustment.
- NSFW content warning toggle.
- App version and legal info.

## 5. Screen Map

```
App
├── MainTabs (BottomNavBar)
│   ├── HomeTab
│   │   └── PostDetailScreen
│   │       ├── ImageViewerScreen
│   │       └── CommentSection (inline)
│   ├── RecentTab
│   │   └── PostDetailScreen → (shared)
│   ├── SearchTab
│   │   └── PostDetailScreen → (shared)
│   └── SettingsTab
│       ├── LoginScreen (WebView)
│       ├── ScrapListScreen
│       └── ReadHistoryScreen
└── NsfwWarningDialog (first launch overlay)
```

Navigation rules:
- Bottom tabs: instant switch, no back stack.
- Post tap → PostDetailScreen (push).
- Image tap → ImageViewerScreen (push, shared element transition).
- Back → pop to previous screen.

## 6. Screen Requirements

### PostDetailScreen — Phase: P0

- Body: text + inline images + inline video.
- Images: tap to open fullscreen viewer (shared element transition).
- Video: in-app playback with fullscreen toggle.
- Actions: recommend / not-recommend buttons + counts (P2, login required).
- Author info: nickname, icon, timestamp.
- Comments: best comments pinned at top, then full list.
- Comment input (P2, login required).
- Scrap/bookmark button.
- Share post link (P2).

### ImageViewerScreen — Phase: P0

- Fullscreen, black background, status bar hidden.
- Left/right swipe between images in the post.
- Pinch to zoom, double-tap to reset.
- Position indicator: "3 / 12".
- Save to gallery (P3).

### LoginScreen — Phase: P2

- WebView loading `web.humoruniv.com/user/login.html`.
- On success: extract cookies, store in app's HTTP client.
- Auto-detect session expiry and prompt re-login.

### SearchResult — Phase: P1

- Same post cards as RecentTab.
- Empty state: "No results found" with suggestion to adjust filter.

## 7. User Flows

### Flow 1: First Launch

```
App Open → Splash (logo) → NSFW Warning Dialog
  → "Acknowledge" → HomeTab (cached or empty state)
  → Background fetch → Best posts appear
```

### Flow 2: Content Consumption

```
HomeTab → See hero card → Tap → PostDetailScreen
  → Read text → Tap image → ImageViewerScreen
  → Swipe through images → Back → PostDetailScreen
  → Scroll to comments → Read best comments
  → Back → HomeTab
```

### Flow 3: Search

```
SearchTab → Tap search bar → Type query (debounced)
  → Select period filter → Results appear
  → Tap result → PostDetailScreen → Back → SearchTab
```

### Flow 4: Login + Interaction (P2)

```
SettingsTab → Tap "Login" → LoginScreen (WebView)
  → Enter credentials → Success → SettingsTab (shows logged-in state)
  → Navigate to PostDetailScreen → Tap "Recommend"
  → POST request → Success → Count updates
```

## 8. Interaction Patterns

### Screen Transitions

- Tab switch: instant, no animation.
- Forward navigation: platform default (slide on iOS, fade on Android).
- Back navigation: system back gesture/button.
- Image viewer: shared element transition (hero animation).

### Gestures

- Pull-to-refresh: all list screens (Home, Recent, Search results).
- Infinite scroll: RecentTab, Search results (pagination trigger at 80% scroll).
- Swipe: image viewer left/right navigation.
- Pinch-to-zoom: image viewer.
- Double-tap: image viewer reset zoom.

### Feedback Patterns

- Recommend/Not-recommend: optimistic count update, revert on error.
- Loading: skeleton/shimmer for list screens, spinner for detail.
- Error: inline error message with retry button, never blank screen.
- Empty state: illustration + message + suggested action.
- Offline: cached content with "Last updated X minutes ago" banner.
- NSFW: first launch warning dialog, settings toggle for ongoing control.

## 9. Feature Roadmap

### Phase 0: Spike (3-4 days)

Prove the architecture works end-to-end with one full TDD cycle.

- [x] Install all dependencies (riverpod, dio, html, charset_converter, dartz, go_router, get_it).
- [x] Set up DI container (`di/injection.dart`).
- [x] Build `HtmlClient` with EUC-KR decoding via `charset_converter`.
- [x] Build `HumorUnivRemoteDs` with rate limiting (minimum 2s between requests).
- [x] Write `PdsParser.parseBestPosts()` with fixture HTML.
- [x] Complete one full TDD cycle: test -> parser -> use case -> repository -> provider -> screen.
- [ ] Spike: attempt a POST request for recommend to assess write operation feasibility.

**Exit criteria**: Main screen displays real best posts from humoruniv.com.

### Phase 1: MVP (1.5-2 weeks)

Read-only humor content viewer.

| ID | Feature | Priority |
|----|---------|----------|
| F-01 | Home: best posts list with hero card | P0 |
| F-02 | Recent: full post list with filters and pagination | P0 |
| F-03 | Post detail: text + images + video + comments (read) | P0 |
| F-04 | Image viewer: fullscreen, swipe, pinch-zoom | P0 |
| F-05 | Search: keyword + period filter | P1 |
| F-06 | Read post tracking (local storage) | P1 |
| F-07 | Dark mode (system-aware) | P1 |
| F-08 | In-memory caching with TTL | P1 |
| F-09 | Rate limiting / polite scraping (min 2s between requests) | P0 |
| F-10 | Error states: network error, parse error, empty state | P0 |
| F-11 | NSFW content warning on first launch + settings toggle | P0 |
| F-12 | Pull-to-refresh on all list screens | P1 |

**MVP exit criteria**: App is listed on store. User can browse, read, and search humor posts with a better experience than mobile web.

### Phase 2: Auth + Interactions (2-3 weeks)

Login and active participation. Write operations are high-risk and may be cut.

| ID | Feature | Priority | Risk |
|----|---------|----------|------|
| F-13 | Login via WebView + cookie management | P0 | Medium |
| F-14 | Recommend / not-recommend | P0 | **High** (POST + CSRF) |
| F-15 | Comment write | P1 | **High** (POST + CSRF) |
| F-16 | Scrap / bookmark (local + server) | P1 | Low |
| F-17 | Favorite boards pin | P2 | Low |
| F-18 | Deep linking (open humoruniv URLs in app) | P1 | Low |
| F-19 | Share post link | P1 | Low |
| F-20 | User block list | P2 | Medium |
| F-21 | Font size setting | P2 | Low |
| F-22 | 6 color themes | P3 | Low |

**Write operation disclaimer**: Recommend, comment write, and scrap sync require POST requests against a form-based site with CSRF tokens. These features are marked **High risk** and will be spiked in Phase 0. If the POST flow proves fragile, the app will be positioned as a "view-only companion" and these features will be cut.

### Phase 3: Expansion (future)

| ID | Feature | Notes |
|----|---------|-------|
| F-23 | Additional boards | Most boards share the same HTML template as pds. Parser reuse likely. |
| F-24 | Write posts (image/video attach) | Requires full form POST reverse-engineering. |
| F-25 | Offline disk cache (Hive/Isar) | Persist parsed DTOs + images for offline reading. |
| F-26 | Gallery save | Android 13+ granular permissions. |
| F-27 | Home screen widget (Android) | Requires background scraping — complex. |
| F-28 | Tablet layout | Low priority for Korean humor community demographics. |

## 10. Risk Management

| Risk | Impact | Mitigation |
|------|--------|------------|
| Site HTML structure changes | Parser breaks, app shows errors | Single parser = single point of fix. Graceful degradation: show cached data + error message. Fast hotfix deployment. |
| Site blocks app access | All features fail | Set User-Agent to standard mobile browser. Prepare WebView fallback mode as emergency option. |
| Write operations fail (CSRF/session) | Phase 2 features cut | Spike in Phase 0. If fragile, reposition as view-only app. Do not commit to write features until proven. |
| Login cookie expiry | Auth features stop working | Auto-detect expiry + prompt re-login. Show clear session-expired UI. |
| App store rejection | Cannot distribute | App is not a web wrapper: native image viewer, caching, offline support, search. Non-commercial use stated. |
| Content copyright issues | Legal risk | App is a viewer. Content belongs to original authors. App does not modify or create content. |
| Aggressive scraping triggers IP ban | App stops working | Rate limiting (min 2s between requests). Cache aggressively. Respect the source site. |

## 11. Success Metrics

| Phase | Metric | Target |
|-------|--------|--------|
| Phase 1 | App store listing live | Yes/No |
| Phase 1 | Crash rate | < 2% |
| Phase 1 | App store rating | 4.0+ |
| Phase 2 | Monthly active users | 300+ |
| Phase 2 | Posts viewed per session | 10+ |
| Phase 2 | Logged-in user ratio | 30%+ |
| Phase 3 | Monthly active users | 1,000+ |
| Phase 3 | Crash rate | < 0.5% |

Measurement: Firebase Analytics (client-side SDK, not a backend server).

## 12. Timeline

```
Week 1        Phase 0: Spike — prove architecture, one TDD cycle
Week 2-3      Phase 1: MVP — read-only viewer
              ── MVP Release ──
Week 4-6      Phase 2: Auth + interactions (write ops high-risk)
              ── Growth Release ──
Week 7+       Phase 3: Expansion — more boards, offline, advanced features
```
