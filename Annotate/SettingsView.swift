import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Annotate Hotkey:", name: .toggleOverlay)
        }
        .padding()
        .frame(width: 300)
    }
}
