import Foundation

/// Owns the lifecycle of the bundled `cli.py dashboard` Python process:
/// spawn it against a free loopback port, poll until it answers HTTP, and
/// kill it when the app quits. Mirrors the state machine the project's own
/// VS Code extension uses in `vscode-extension/src/server-manager.ts`.
final class ServerManager: ObservableObject {
    enum Status: Equatable {
        case starting
        case ready(url: URL)
        case failed(String)
    }

    @Published private(set) var status: Status = .starting

    private var process: Process?
    private let candidatePorts = [8877, 8878, 8879, 8890, 8891]

    func start() {
        tryNextPort(index: 0)
    }

    func stop() {
        process?.terminate()
        process = nil
    }

    private func tryNextPort(index: Int) {
        guard index < candidatePorts.count else {
            DispatchQueue.main.async {
                self.status = .failed("Could not find a free port for the dashboard server.")
            }
            return
        }
        let port = candidatePorts[index]

        guard let pythonURL = Self.locatePython3() else {
            DispatchQueue.main.async {
                self.status = .failed("python3 was not found on this Mac. Install Python 3 to run Claude Usage.")
            }
            return
        }
        guard let scriptPath = Bundle.main.path(forResource: "cli", ofType: "py", inDirectory: "pysrc") else {
            DispatchQueue.main.async {
                self.status = .failed("Bundled cli.py not found inside the app.")
            }
            return
        }
        let workingDir = (scriptPath as NSString).deletingLastPathComponent

        let proc = Process()
        proc.executableURL = pythonURL
        proc.currentDirectoryURL = URL(fileURLWithPath: workingDir)
        proc.arguments = [
            scriptPath, "dashboard",
            "--no-browser",
            "--host", "127.0.0.1",
            "--port", String(port),
            "--surface", "mac",
        ]

        let stdout = Pipe()
        let stderr = Pipe()
        proc.standardOutput = stdout
        proc.standardError = stderr

        var exitedEarly = false
        proc.terminationHandler = { [weak self] p in
            if p.terminationStatus != 0 {
                exitedEarly = true
                DispatchQueue.main.async {
                    if case .ready = self?.status {
                        self?.status = .failed("Dashboard server exited unexpectedly.")
                    } else {
                        // Likely a port collision — try the next candidate.
                        self?.tryNextPort(index: index + 1)
                    }
                }
            }
        }

        do {
            try proc.run()
        } catch {
            tryNextPort(index: index + 1)
            return
        }
        process = proc

        let url = URL(string: "http://127.0.0.1:\(port)/")!
        pollReadiness(url: url, deadline: Date().addingTimeInterval(15), exitedEarly: { exitedEarly })
    }

    private func pollReadiness(url: URL, deadline: Date, exitedEarly: @escaping () -> Bool) {
        if exitedEarly() { return }
        if Date() > deadline {
            DispatchQueue.main.async {
                self.status = .failed("Dashboard server did not respond within 15 seconds.")
            }
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 1.0
        let task = URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                DispatchQueue.main.async {
                    self.status = .ready(url: url)
                }
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                    self.pollReadiness(url: url, deadline: deadline, exitedEarly: exitedEarly)
                }
            }
        }
        task.resume()
    }

    private static func locatePython3() -> URL? {
        let candidates = [
            "/usr/bin/python3",
            "/opt/homebrew/bin/python3",
            "/usr/local/bin/python3",
            "/Library/Frameworks/Python.framework/Versions/Current/bin/python3",
        ]
        for path in candidates where FileManager.default.isExecutableFile(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        // Fall back to whatever `python3` resolves to on the user's PATH.
        let which = Process()
        which.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        which.arguments = ["which", "python3"]
        let pipe = Pipe()
        which.standardOutput = pipe
        do {
            try which.run()
            which.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let path = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
               !path.isEmpty {
                return URL(fileURLWithPath: path)
            }
        } catch {
            return nil
        }
        return nil
    }
}
