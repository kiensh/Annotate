import KeyboardShortcuts
import SwiftUI

@main
struct AnnotateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        KeyboardShortcuts.onKeyDown(for: .toggleOverlay) {
            AppDelegate.shared?.toggleOverlay()
        }
    }

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
