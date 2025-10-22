import Foundation

// MARK: - Keyboard Shortcuts
//
// All shortcuts are designed for LEFT-HAND operation (right hand stays on mouse)
//
// Layout on QWERTY keyboard:
//   Q W E R T     Q=Pen(Quick), W=Line(Wall), E=Highlighter(Emphasize), R=Rectangle, T=Text
//   A S D F G     A=Arrow, S=LineWidth(Stroke/Size), D=Counter(Digit)
//   Z X C V B     X=ColorPicker(miX), C=Circle, V=Select, B=Board
//
// Mnemonic tips:
//   - Q: Quick drawing (Pen) - top-left corner, most accessible
//   - W: Wall/Wire (Line) - straight lines
//   - E: Emphasize (Highlighter) - make text stand out
//   - S: Stroke/Size (Line Width) - adjust thickness
//   - D: Digit/Dot (Counter) - numbered circles
//   - X: miX colors (Color Picker)
//   - All other keys match first letter of tool name

enum ShortcutKey: String, CaseIterable {
    case pen = "q"              // Q - Quick drawing (top-left, most accessible)
    case arrow = "a"            // A - Arrow
    case line = "w"             // W - Wall/Wire (straight line)
    case highlighter = "e"      // E - Emphasize
    case rectangle = "r"        // R - Rectangle
    case circle = "c"           // C - Circle
    case counter = "d"          // D - Digit/Dot counter
    case text = "t"             // T - Text
    case select = "v"           // V - Select (standard across apps)
    case colorPicker = "x"      // X - miX colors
    case lineWidthPicker = "s"  // S - Stroke/Size width
    case toggleBoard = "b"      // B - Board

    var defaultKey: String { rawValue }

    var displayName: String {
        switch self {
        case .pen: return "Pen"
        case .arrow: return "Arrow"
        case .line: return "Line"
        case .highlighter: return "Highlighter"
        case .rectangle: return "Rectangle"
        case .circle: return "Circle"
        case .counter: return "Counter"
        case .text: return "Text"
        case .select: return "Select"
        case .colorPicker: return "Color Picker"
        case .lineWidthPicker: return "Line Width"
        case .toggleBoard: return "Toggle Board"
        }
    }
}

@MainActor
class ShortcutManager: @unchecked Sendable {
    static let shared = ShortcutManager()

    private let defaults = UserDefaults.standard
    private let shortcutPrefix = "shortcut."

    private init() {}

    func getShortcut(for tool: ShortcutKey) -> String {
        defaults.string(forKey: shortcutPrefix + tool.rawValue) ?? tool.defaultKey
    }

    func setShortcut(_ key: String, for tool: ShortcutKey) {
        if isShortcutTaken(key, excluding: tool) {
            print("Shortcut '\(key)' is already in use.")
            return
        }
        defaults.set(key, forKey: shortcutPrefix + tool.rawValue)
        defaults.synchronize()
    }

    func resetToDefault(tool: ShortcutKey) {
        defaults.removeObject(forKey: shortcutPrefix + tool.rawValue)
        defaults.synchronize()
    }

    func resetAllToDefault() {
        ShortcutKey.allCases.forEach { resetToDefault(tool: $0) }
    }

    func isShortcutTaken(_ key: String, excluding tool: ShortcutKey) -> Bool {
        for otherTool in ShortcutKey.allCases where otherTool != tool {
            if getShortcut(for: otherTool) == key {
                return true
            }
        }
        return false
    }
}

extension ShortcutManager {
    var allShortcuts: [ShortcutKey: String] {
        Dictionary(uniqueKeysWithValues: ShortcutKey.allCases.map { ($0, getShortcut(for: $0)) })
    }
}
