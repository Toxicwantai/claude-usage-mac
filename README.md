# Claude Usage Mac

An open source native macOS app for [phuryn/claude-usage](https://github.com/phuryn/claude-usage), a local dashboard that tracks Claude Code token usage, costs, and session history.

Instead of running `python cli.py dashboard` and opening a browser tab, this launches the same dependency free Python dashboard as a background process and shows it in a real app window (`WKWebView`), with a Dock icon like any other Mac app.

## How it works

- `pysrc/` is a vendored copy of upstream's `cli.py`, `dashboard.py`, and `scanner.py` (v1.5.5), stdlib only Python with no third party dependencies.
- On launch, `ServerManager.swift` spawns `python3 cli.py dashboard --no-browser --host 127.0.0.1 --port <port>` (bundled inside `Contents/Resources/pysrc`), polls until it answers HTTP, then loads that URL into a `WKWebView`.
- On quit, the Python process is terminated.
- Reads `~/.claude/projects/*.jsonl` and stores stats in `~/.claude/usage.db`, exactly like the upstream CLI. Nothing about the data path changes.

## Build

```
xcodegen generate
xcodebuild -project ClaudeUsageMac.xcodeproj -scheme ClaudeUsageMac -configuration Release build
```

Or open `ClaudeUsageMac.xcodeproj` in Xcode after running `xcodegen generate` and hit Run.

Requires Xcode, `xcodegen` (`brew install xcodegen`), and Python 3 on the machine running it.

## Updating the vendored Python source

Pull the latest `cli.py`, `dashboard.py`, and `scanner.py` from upstream into `pysrc/` and rebuild. No other changes are needed since the CLI interface (`dashboard --no-browser --host --port`) is stable.

## Notes

This is an unofficial, unsigned wrapper. It is not affiliated with phuryn or Anthropic. macOS Gatekeeper may warn on first launch since the app is not notarized. Right click the app and choose Open to bypass that once.

## License

MIT. See LICENSE.

This project bundles source files from phuryn/claude-usage under `pysrc/`. Those files keep their original MIT license, Copyright (c) 2026 Pawel Huryn, see `pysrc/LICENSE`.
