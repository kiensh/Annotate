import SwiftUI

struct ShortcutField: View {
    let tool: ShortcutKey
    @Binding var shortcuts: [ShortcutKey: String]
    @Binding var editingShortcut: ShortcutKey?

    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("", text: .constant("Press any key"))
            .frame(width: 100)
            .multilineTextAlignment(.center)
            .background(Color(NSColor.controlBackgroundColor))
            .padding(.all, 0)
            .cornerRadius(6)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: NSControl.textDidChangeNotification)
            ) { _ in
                if let event = NSApp.currentEvent, event.type == .keyDown {
                    let key = event.characters?.lowercased() ?? ""
                    if !key.isEmpty {
                        ShortcutManager.shared.setShortcut(key, for: tool)
                        shortcuts = ShortcutManager.shared.allShortcuts

                        if let appDelegate = AppDelegate.shared {
                            appDelegate.updateMenuKeyEquivalents()
                        }
                    }
                    editingShortcut = nil
                }
            }
    }
}
