# Session Handoff: claude-usage-mac, initial build + open source

Date: 2026-07-14
Read this FIRST if resuming this project. Then check `git log` and `git status` to confirm nothing drifted since.

## 1. What we're building

A native macOS wrapper app around [phuryn/claude-usage](https://github.com/phuryn/claude-usage), an open source, dependency-free Python tool that reads Claude Code's local JSONL transcripts (`~/.claude/projects/*.jsonl`), stores stats in SQLite (`~/.claude/usage.db`), and serves a Chart.js usage/cost dashboard. Upstream runs it as `python cli.py dashboard` and opens a browser tab at `localhost:8080`.

The user's exact ask, verbatim: **"can we make this https://github.com/phuryn/claude-usage an actual mac app (not on the app store like just for myself) Make it a mac app instead of locahost."**

So the job was: wrap the same dashboard in a real SwiftUI macOS app (Dock icon, app window) instead of a browser tab, for the user's personal use only, explicitly NOT for App Store distribution.

This is a small side build, not one of the user's serious B2C bets (contrast with yidiantong, peka, jiele, etc. in memory). Treat it as a quick personal tool, not a product.

## 2. Current state

- Project lives at `~/Desktop/claude-usage-mac/`.
- Git repo initialized, pushed to `https://github.com/Toxicwantai/claude-usage-mac`, **PUBLIC**, **MIT licensed** (GitHub correctly detects "MIT" as of the last commit, verified via `gh api repos/Toxicwantai/claude-usage-mac/license`).
- 3 commits on `main`, all pushed, nothing uncommitted (`git status` is clean as of end of session):
  1. `e017a8e` "Native macOS wrapper for phuryn/claude-usage dashboard" (initial build)
  2. `b2ed74e` "Open source the project with an MIT license" (added LICENSE with a bug, see Gotchas)
  3. `a7e8a16` "Keep LICENSE as plain MIT text for GitHub license detection" (fixed the bug)
- Repo description: "Native macOS app for the phuryn claude usage Claude Code token usage dashboard". Topics: `macos`, `swiftui`, `claude-code`, `dashboard`.
- Builds successfully (Debug and Release, unsigned, verified with `xcodebuild`).
- Verified END TO END at the HTTP level: launched the built `.app` directly, confirmed the bundled Python subprocess spawns (`cli.py dashboard --no-browser --host 127.0.0.1 --port 8877 --surface mac`), confirmed `curl http://127.0.0.1:8877/` returns 200 with the real dashboard HTML, and `curl http://127.0.0.1:8877/api/data` returns real usage JSON (actual token/model/session data from this Mac's `~/.claude/usage.db`).
- **NOT visually verified.** `screencapture` failed in this environment ("could not create image from display", Screen Recording permission not granted to the shell). Never got a literal pixel screenshot confirming the WKWebView renders the dashboard correctly on screen (charts, layout, no JS console errors). Only confirmed the HTTP server side is correct. The user should open the app and eyeball it themselves.
- **Currently running right now** (as of end of session): the app process and its Python subprocess are alive on this Mac from my last test launch:
  - `ClaudeUsageMac.app/Contents/MacOS/ClaudeUsageMac` (PID was 56862 at last check)
  - Python subprocess serving on `127.0.0.1:8877` (PID was 56865 at last check)
  - This is harmless (loopback only) but the user may want to just Cmd+Q it and relaunch fresh, or leave it running.
- The built `.app` sits at `~/Desktop/claude-usage-mac/ClaudeUsageMac.app` (Release build, copied there for convenience). It is **gitignored**, not tracked, not yet in `/Applications`.
- **The user has NOT yet dragged the app into `/Applications`.** That was their explicit choice (see Decided section) — I should not do this for them unless asked.

## 3. DECIDED (locked)

- **Not App Store, personal use only.** User's exact words: *"can we make this https://github.com/phuryn/claude-usage an actual mac app (not on the app store like just for myself)"*. Do not add App Store provisioning, MAS sandboxing, or in-app purchase flows later without re-confirming this is still the intent.
- **Regular Dock app**, not a menu bar utility, not "both". Asked via AskUserQuestion: "How should the app live on your Mac?" User picked **"Regular Dock app"** over "Menu bar app (Recommended)" and "Both". This was a deliberate choice against my own recommendation, don't second-guess it.
- **Project + app location: `~/Desktop/claude-usage-mac`.** Asked via AskUserQuestion: "Where should I put the project and app?" User picked **"~/Desktop/claude-usage-mac (Recommended)"**, whose description explicitly said *"I'll build the .app there and you can drag it to /Applications yourself"* — over the alternative "Build straight to /Applications". This means: **do not copy the app into /Applications automatically**, that's the user's job, by their own choice.
- **Make the GitHub repo public and open source it.** User's exact words: *"And also make this github repo public and opensource"*. Done: visibility flipped to public, MIT LICENSE added at the repo root.
- **No dashes or emojis on the GitHub repo.** User's exact words: *"Don't add dashes or emojis on the github repo."* Applied to: README.md, LICENSE, Swift code comments, repo description. Verified via `grep` for em dash (`—`) and en dash (`–`) across `*.md`, `*.swift`, `*.yml`, `*.plist` (excluding the vendored `pysrc/` files, which are upstream's own text and weren't touched for style). Found and fixed 4 lines in README.md and 1 in `ServerManager.swift`.
- **Bundle identifier: `com.wantai.claudeusage`.** Not explicitly requested this session, but matches the user's established `com.wantai.*` convention seen across other projects (peka, jiele, bingbong, etc. per standing memory). I chose this myself as a consistent default; flagging it as decided-by-me-not-by-user in case they want something else.

## 4. OPEN (needs me / needs the user)

- **DO NOT resolve by guessing: does "no dashes" extend to GitHub repo topics?** I added topics `macos`, `swiftui`, `claude-code`, `dashboard`. The topic `claude-code` contains a hyphen. GitHub topics can't contain spaces, so a fully hyphen-free version would have to be something like `claudecode` instead. I left it as `claude-code` since that's the conventional GitHub topic spelling and topics are metadata/slugs, not prose, but the user's instruction was blanket ("don't add dashes... on the github repo") and I did not go back and ask before publishing it. If this matters to them, ASK, don't just silently change it or silently leave it.
- **Visual correctness of the WKWebView is unconfirmed.** I could not screenshot (see Gotchas). The user should open the app and check that the dashboard actually renders (charts, layout, dark theme, no blank/broken page) before considering this "done done". If something's visually broken, that's the first thing to debug next session.
- **App icon.** I generated `AppIcon.appiconset` by running `sips` against upstream's own `vscode-extension/resources/icon_large.png` (their dashboard logo), at no point did the user ask for or approve a specific icon. This was my own judgment call to have *some* real icon rather than the Xcode default gray one. If the user wants a different/custom icon, that's open and undiscussed.
- **Repo description wording** ("Native macOS app for the phuryn claude usage Claude Code token usage dashboard") reads a little awkwardly because I avoided the natural "phuryn/claude-usage" slash notation to dodge anything dash-adjacent. This was my own phrasing call, not confirmed with the user. Happy to tighten it if asked.
- **Chart.js is loaded from a CDN** (`cdn.jsdelivr.net`) inside the dashboard HTML, inherited unchanged from upstream. This means charts need internet access to render even though the data itself is 100% local. Never discussed with the user; flagging as a possible surprise if they use the app fully offline. This is upstream's own design, not something I introduced, and I did not change it.

## 5. MY PREFERENCES, VETOES & SMALL ASKS (verbatim, small stuff)

- *"not on the app store like just for myself"* — personal use only, hard constraint.
- *"Make it a mac app instead of locahost"* [sic] — the core ask.
- Explicitly chose **"Regular Dock app"** over a menu bar app when I recommended the menu bar option first. Don't re-suggest menu bar without being asked.
- Explicitly chose to build at `~/Desktop/claude-usage-mac` and drag to `/Applications` themselves, rather than have me build straight into `/Applications`.
- *"Don't add dashes or emojis on the github repo."* — applies to all prose I write into this repo (README, LICENSE, descriptions, comments). No exceptions volunteered by me; the one hyphen left in is in a GitHub topic slug (`claude-code`), flagged above as unresolved, not a knowing exception.
- No tone/style guidance was given beyond this. The user did not ask for screenshots and I did not send any (consistent with the standing memory `feedback_dont_send_screenshots.md` — user checks apps themselves).

## 6. Files that matter

- `~/Desktop/claude-usage-mac/project.yml` — xcodegen spec, the source of truth for the Xcode project. Bundle id `com.wantai.claudeusage`, macOS 13.0 deployment target, unsigned/non-sandboxed (`ENABLE_HARDENED_RUNTIME: NO`, no entitlements file), `pysrc` declared under `sources:` with `type: folder, buildPhase: resources` (see Gotchas for why this exact form matters).
- `~/Desktop/claude-usage-mac/ClaudeUsageMac.xcodeproj` — **GENERATED, gitignored.** Regenerate with `xcodegen generate` before opening in Xcode or building; do not hand-edit it, do not expect it to exist fresh from a clean clone.
- `~/Desktop/claude-usage-mac/ClaudeUsageMac/ClaudeUsageMacApp.swift` — SwiftUI `App` entry point + `AppDelegate` (kills the Python subprocess on quit via `applicationWillTerminate`).
- `~/Desktop/claude-usage-mac/ClaudeUsageMac/ContentView.swift` — hosts the `WKWebView`; renders a starting spinner, the webview once ready, or a retry screen on failure.
- `~/Desktop/claude-usage-mac/ClaudeUsageMac/ServerManager.swift` — owns the Python subprocess lifecycle. Candidate ports `[8877, 8878, 8879, 8890, 8891]`, tries each in turn on bind failure, 15 second readiness timeout (polls every 0.2s), looks for `python3` at a few hardcoded paths then falls back to `which python3`.
- `~/Desktop/claude-usage-mac/ClaudeUsageMac/Info.plist` — hand-written (not Xcode-generated), `CFBundleDisplayName` "Claude Usage", category `public.app-category.developer-tools`, `NSAllowsLocalNetworking: true` for loopback ATS.
- `~/Desktop/claude-usage-mac/ClaudeUsageMac/Assets.xcassets/AppIcon.appiconset/` — icon set generated via `sips` from upstream's `icon_large.png`.
- `~/Desktop/claude-usage-mac/pysrc/` — **vendored copy** of upstream's `cli.py`, `dashboard.py`, `scanner.py`, `LICENSE`, plus `vscode-extension/resources/icon.svg` (nested path deliberately preserved, see Gotchas). Currently vendored at upstream **v1.5.5**. To update: pull the latest 3 `.py` files from `phuryn/claude-usage` into this folder and rebuild, no other changes needed since the CLI interface is stable.
- `~/Desktop/claude-usage-mac/LICENSE` — root MIT license. **Keep this file as pure, unmodified canonical MIT text.** Do not append extra paragraphs to it (see Gotchas for why).
- `~/Desktop/claude-usage-mac/README.md` — public facing readme, dash free, credits phuryn/claude-usage, explains build steps and the pysrc update process.
- `~/Desktop/claude-usage-mac/.gitignore` — ignores `build/`, `DerivedData/`, `ClaudeUsageMac.xcodeproj/`, `ClaudeUsageMac.app/`, `pysrc/__pycache__/`.
- `~/Desktop/claude-usage-mac/ClaudeUsageMac.app` — local-only Release build, gitignored, not in `/Applications` yet.
- `~/Desktop/claude-usage-mac/build/` — Xcode build output (Debug + Release products), gitignored, ephemeral, regenerate by rebuilding.

## 7. Gotchas & dead ends

1. **xcodegen 2.45.4 has no top-level `resources:` key on a target.** My first attempt used `resources: [- path: pysrc/cli.py, ...]` at the target level. `xcodegen generate` ran with no error, but silently produced an **empty** Resources build phase, nothing was actually bundled. Confirmed by grepping the generated `.pbxproj`. Fixed by moving `pysrc` under `sources:` with `type: folder` (folder reference, preserves the subfolder structure) and `buildPhase: resources` (forces non-auto-detected `.py` files into Copy Bundle Resources, since they're not images/xibs/json which get auto-detected). Confirmed the correct pattern via WebFetch of `https://raw.githubusercontent.com/yonaskolb/XcodeGen/master/Docs/ProjectSpec.md`. If you ever add more bundled resources, use this same `sources:` + `type: folder` + `buildPhase: resources` pattern, not a bare `resources:` key.
2. **Because `pysrc` is a folder reference, `Bundle.main.path(forResource:ofType:)` needs `inDirectory: "pysrc"`** as an explicit argument. Without it, the lookup returns `nil` since that API does not search into subdirectories by default. Already fixed in `ServerManager.swift`, just noting why the code looks the way it does.
3. **GitHub's `licensee` license detector needs LICENSE to closely match a canonical template.** First version of LICENSE had the standard MIT text plus an extra paragraph crediting `phuryn/claude-usage` for the vendored files. That extra paragraph made GitHub detect the license as "Other" / `NOASSERTION` instead of "MIT" (confirmed via `gh api repos/.../license`). Fixed by moving the attribution sentence into README.md's License section and keeping LICENSE byte-for-byte a standard MIT template (just the copyright year/holder line differs). **Lesson: never append anything to a LICENSE file beyond the standard template text, put notes elsewhere.**
4. **`gh repo edit --visibility public` needs `--accept-visibility-change-consequences`** on this `gh` CLI version, or it will not apply (I passed it, it worked).
5. **`screencapture -x` fails in this shell/environment** with "could not create image from display", Screen Recording permission isn't granted to the terminal. Don't waste time retrying the same way in a future session; either ask the user to grant that permission, or rely on HTTP-level verification (curl the URL the WKWebView loads) plus asking the user to eyeball it themselves.
6. **My own quick session-level cost analysis overestimated total spend.** I wrote a scratch Python script that summed `sessions_all` from `/api/data`, assuming each session used a single model for all its turns. That gave **$828.74**, which is WRONG. The authoritative number is from `python3 pysrc/cli.py stats`, which attributes cost per actual turn (a single session can mix models, e.g. an orchestrator turn on `claude-fable-5` plus many subagent turns on `claude-opus-4-8` within the *same* session_id) and correctly totaled **$611.90**. If token-cost analysis comes up again, always defer to `cli.py stats`'s per-model breakdown for the dollar figure; only use the session-level rows to identify which sessions/topics are heavy, never to quote an exact per-session cost.
7. **The Python resolved at runtime in my test was Xcode's own bundled Python 3.9** (`/Applications/Xcode.app/Contents/Developer/Library/Frameworks/Python3.framework/Versions/3.9/Resources/Python.app/Contents/MacOS/Python`), reached via the `which python3` fallback in `ServerManager.locatePython3()`, not one of the 4 hardcoded candidate paths. Worked fine since the vendored scripts are stdlib-only, just noting it in case Python-version-specific weirdness ever surfaces.
8. **Deleted `~/Desktop/claude-usage-src`** after vendoring what was needed. That was a scratch clone of upstream used only for research and copying files into `pysrc/`. It no longer exists; don't look for it, don't recreate it unless you need to diff against a fresh upstream checkout again.

## 8. Next steps, in order

1. User opens/checks `~/Desktop/claude-usage-mac/ClaudeUsageMac.app` themselves and visually confirms the dashboard renders correctly (this has only been verified at the HTTP level, not visually).
2. If happy, user drags the app into `/Applications` themselves (their explicit choice, don't do it for them).
3. Resolve the open question on whether the `claude-code` GitHub topic hyphen is acceptable, or should be renamed/removed, by asking, not guessing.
4. No code changes are pending. Repo is clean and pushed to `a7e8a16` on `origin/main`.
5. If the user later wants to pull upstream updates into `pysrc/`, see the update instructions in `README.md`.

## 9. Uncertain / flag explicitly

- I do not know if the user is satisfied with the token-savings analysis I gave them (heavy subagent/Task fan-out and Fable-5 usage as the two biggest cost levers, based on real data from their own `~/.claude/usage.db`). That advice was given but not explicitly confirmed back to me as useful or acted upon.
- I do not know if the user wants this repo's existence or its token-cost findings shared anywhere (e.g. as a blog post, a tweet, Product Hunt). Nothing was said either way, don't assume either way.
- I am not fully certain the WKWebView's rendering of the dashboard is pixel-correct (see Gotcha #5 and Open item on visual verification). Treat "it works" as "verified at the network/data layer, not the pixel layer" until the user confirms otherwise.
