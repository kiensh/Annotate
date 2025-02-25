import Foundation
import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaults.clearDrawingsOnStartKey) private var clearDrawingsOnStart = false

    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    KeyboardShortcuts.Recorder("Annotate Hotkey:", name: .toggleOverlay)
                }

                HStack {
                    Text("Clear drawings when toggling overlay")
                    Toggle("", isOn: $clearDrawingsOnStart)
                        .labelsHidden()
                }
                .help("When enabled, all drawings will be cleared each time you toggle the overlay")
            }
        }
        .padding()
        .frame(width: 320)
    }
}
