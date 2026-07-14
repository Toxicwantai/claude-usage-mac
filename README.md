# Claude Usage (Mac app)

A native macOS wrapper around [phuryn/claude-usage](https://github.com/phuryn/claude-usage) — for personal use only, not distributed via the App Store.

Instead of running `python cli.py dashboard` and opening a browser tab, this launches the same dependency-free Python dashboard as a background process and shows it in a real app window (`WKWebView`), with a Dock icon like any other Mac app.

## How it works

- `pysrc/` is a vendored copy of upstream's `cli.py`, `dashboard.py`, `scanner.py` (v1.5.5) — stdlib-only Python, no third-party deps.
- On launch, `ServerManager.swift` spawns `python3 cli.py dashboard --no-browser --host 127.0.0.1 --port <port>` (bundled inside `Contents/Resources/pysrc`), polls until it answers HTTP, then loads that URL into a `WKWebView`.
- On quit, the Python process is terminated.
- Reads `~/.claude/projects/*.jsonl` and stores stats in `~/.claude/usage.db`, exactly like the upstream CLI — nothing about the data path changes.

## Build

```
xcodegen generate
xcodebuild -project ClaudeUsageMac.xcodeproj -scheme ClaudeUsageMac -configuration Release build
```

Or just open `ClaudeUsageMac.xcodeproj` in Xcode after running `xcodegen generate` and hit Run.

## Updating the vendored Python source

Pull the latest `cli.py` / `dashboard.py` / `scanner.py` from upstream into `pysrc/` and rebuild — no other changes needed since the CLI interface (`dashboard --no-browser --host --port`) is stable.
