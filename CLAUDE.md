Read `SESSION_HANDOFF_2026-07-14_initial-build-and-opensource.md` FIRST before doing anything else in this project.

# claude-usage-mac

Native macOS wrapper (SwiftUI + WKWebView) around [phuryn/claude-usage](https://github.com/phuryn/claude-usage), a local Claude Code token usage dashboard. Personal use only, not App Store distributed. Public and MIT licensed at `https://github.com/Toxicwantai/claude-usage-mac`.

Build: `xcodegen generate` then `xcodebuild -project ClaudeUsageMac.xcodeproj -scheme ClaudeUsageMac -configuration Release build`, or open the generated `.xcodeproj` in Xcode.

See `README.md` for how it works and how to update the vendored Python source in `pysrc/`.
