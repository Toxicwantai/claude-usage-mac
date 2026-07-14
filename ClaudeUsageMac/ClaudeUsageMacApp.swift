import SwiftUI

@main
struct ClaudeUsageMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var server = ServerManager()

    var body: some Scene {
        WindowGroup {
            ContentView(server: server)
                .frame(minWidth: 900, minHeight: 650)
                .onAppear {
                    appDelegate.server = server
                    server.start()
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 860)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    var server: ServerManager?

    func applicationWillTerminate(_ notification: Notification) {
        server?.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
