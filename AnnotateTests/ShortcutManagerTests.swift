import XCTest

@testable import Annotate

@MainActor
final class ShortcutManagerTests: XCTestCase, Sendable {
    nonisolated override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            ShortcutManager.shared.resetAllToDefault()
        }
    }

    func testDefaultShortcuts() {
        for tool in ShortcutKey.allCases {
            XCTAssertEqual(
                ShortcutManager.shared.getShortcut(for: tool), tool.defaultKey,
                "Default shortcut for \(tool.displayName) should be \(tool.defaultKey)")
        }
    }

    func testSetNewShortcut() {
        // Set a new shortcut for Pen (provided it doesn't conflict).
        ShortcutManager.shared.setShortcut("f", for: .pen)
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .pen), "f", "Pen shortcut should update to 'f'")
    }

    func testDuplicateShortcutNotAllowed() {
        // Given the default for Arrow is "a", attempt to set Pen to "a".
        ShortcutManager.shared.setShortcut("a", for: .pen)
        // The set should be rejected and Pen remains its default ("q").
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .pen), ShortcutKey.pen.defaultKey,
            "Pen shortcut should not update to 'a' because Arrow already uses it")
    }

    func testResetToDefault() {
        // Change a shortcut and then reset it.
        ShortcutManager.shared.setShortcut("f", for: .pen)
        XCTAssertEqual(ShortcutManager.shared.getShortcut(for: .pen), "f")
        ShortcutManager.shared.resetToDefault(tool: .pen)
        XCTAssertEqual(ShortcutManager.shared.getShortcut(for: .pen), ShortcutKey.pen.defaultKey)
    }

    func testResetAllToDefault() {
        // Change a few shortcuts and then reset all.
        ShortcutManager.shared.setShortcut("f", for: .pen)
        ShortcutManager.shared.setShortcut("y", for: .arrow)
        ShortcutManager.shared.resetAllToDefault()
        for tool in ShortcutKey.allCases {
            XCTAssertEqual(ShortcutManager.shared.getShortcut(for: tool), tool.defaultKey)
        }
    }

    func testIsShortcutTaken() {
        // With defaults in place, Arrow is "a" and Pen is "q".
        XCTAssertTrue(
            ShortcutManager.shared.isShortcutTaken("a", excluding: .pen),
            "The shortcut 'a' is taken by Arrow")
        XCTAssertFalse(
            ShortcutManager.shared.isShortcutTaken("a", excluding: .arrow),
            "Excluding Arrow, 'a' should not be taken")
    }

    func testCounterShortcut() {
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .counter),
            ShortcutKey.counter.defaultKey,
            "Default shortcut for Counter should be 'd'"
        )

        // Set a custom shortcut
        ShortcutManager.shared.setShortcut("m", for: .counter)
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .counter),
            "m",
            "Counter shortcut should be updated to 'm'"
        )

        // Reset to default
        ShortcutManager.shared.resetToDefault(tool: .counter)
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .counter),
            ShortcutKey.counter.defaultKey,
            "Counter shortcut should be reset to default"
        )
    }
    
    func testLineShortcut() {
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .line),
            ShortcutKey.line.defaultKey,
            "Default shortcut for Line should be 'w'"
        )
        
        // Set a custom shortcut for line
        ShortcutManager.shared.setShortcut("k", for: .line)
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .line),
            "k",
            "Line shortcut should be updated to 'k'"
        )
        
        // Reset to default
        ShortcutManager.shared.resetToDefault(tool: .line)
        XCTAssertEqual(
            ShortcutManager.shared.getShortcut(for: .line),
            ShortcutKey.line.defaultKey,
            "Line shortcut should be reset to default"
        )
    }
    
    // MARK: - Left-Hand Keyboard Layout Tests
    
    func testLeftHandKeyboardLayout() {
        // Test that all shortcuts are on the left-hand side of QWERTY keyboard
        // Left-hand keys: Q W E R T A S D F G Z X C V B (and numbers)
        let leftHandKeys = Set(["q", "w", "e", "r", "t", "a", "s", "d", "f", "g", "z", "x", "c", "v", "b", "1", "2", "3", "4", "5"])
        
        for tool in ShortcutKey.allCases {
            let shortcut = tool.defaultKey
            XCTAssertTrue(
                leftHandKeys.contains(shortcut),
                "\(tool.displayName) shortcut '\(shortcut)' should be on the left-hand side of keyboard"
            )
        }
    }
    
    func testAllNewDefaultShortcuts() {
        // Test all new left-hand keyboard shortcuts
        XCTAssertEqual(ShortcutKey.pen.defaultKey, "q", "Pen should be 'q' (Quick drawing)")
        XCTAssertEqual(ShortcutKey.arrow.defaultKey, "a", "Arrow should be 'a'")
        XCTAssertEqual(ShortcutKey.line.defaultKey, "w", "Line should be 'w' (Wall/Wire)")
        XCTAssertEqual(ShortcutKey.highlighter.defaultKey, "e", "Highlighter should be 'e' (Emphasize)")
        XCTAssertEqual(ShortcutKey.rectangle.defaultKey, "r", "Rectangle should be 'r'")
        XCTAssertEqual(ShortcutKey.circle.defaultKey, "c", "Circle should be 'c'")
        XCTAssertEqual(ShortcutKey.counter.defaultKey, "d", "Counter should be 'd' (Digit)")
        XCTAssertEqual(ShortcutKey.text.defaultKey, "t", "Text should be 't'")
        XCTAssertEqual(ShortcutKey.select.defaultKey, "v", "Select should be 'v'")
        XCTAssertEqual(ShortcutKey.colorPicker.defaultKey, "x", "Color Picker should be 'x' (miX)")
        XCTAssertEqual(ShortcutKey.lineWidthPicker.defaultKey, "s", "Line Width should be 's' (Stroke/Size)")
        XCTAssertEqual(ShortcutKey.toggleBoard.defaultKey, "b", "Board should be 'b'")
    }
    
    func testNoShortcutConflicts() {
        // Verify all default shortcuts are unique
        var shortcuts = Set<String>()
        for tool in ShortcutKey.allCases {
            let shortcut = tool.defaultKey
            XCTAssertFalse(
                shortcuts.contains(shortcut),
                "Shortcut '\(shortcut)' is used by multiple tools"
            )
            shortcuts.insert(shortcut)
        }
        
        // Should have 12 unique shortcuts
        XCTAssertEqual(shortcuts.count, ShortcutKey.allCases.count, "All shortcuts should be unique")
    }
    
    func testMnemonicShortcuts() {
        // Test that mnemonic shortcuts match expected keys
        // First-letter matches
        XCTAssertEqual(ShortcutKey.arrow.defaultKey, "a", "Arrow starts with 'a'")
        XCTAssertEqual(ShortcutKey.rectangle.defaultKey, "r", "Rectangle starts with 'r'")
        XCTAssertEqual(ShortcutKey.circle.defaultKey, "c", "Circle starts with 'c'")
        XCTAssertEqual(ShortcutKey.text.defaultKey, "t", "Text starts with 't'")
        XCTAssertEqual(ShortcutKey.toggleBoard.defaultKey, "b", "Board starts with 'b'")
        
        // Mnemonic associations
        XCTAssertEqual(ShortcutKey.pen.defaultKey, "q", "Q for Quick drawing (Pen)")
        XCTAssertEqual(ShortcutKey.line.defaultKey, "w", "W for Wall/Wire (Line)")
        XCTAssertEqual(ShortcutKey.highlighter.defaultKey, "e", "E for Emphasize (Highlighter)")
        XCTAssertEqual(ShortcutKey.lineWidthPicker.defaultKey, "s", "S for Stroke/Size (Line Width)")
        XCTAssertEqual(ShortcutKey.counter.defaultKey, "d", "D for Digit (Counter)")
        XCTAssertEqual(ShortcutKey.colorPicker.defaultKey, "x", "X for miX (Color Picker)")
    }
    
    func testShortcutCustomization() {
        // Verify users can still customize shortcuts
        let customShortcuts = [
            (ShortcutKey.pen, "1"),
            (ShortcutKey.line, "2"),
            (ShortcutKey.highlighter, "3")
        ]
        
        for (tool, customKey) in customShortcuts {
            ShortcutManager.shared.setShortcut(customKey, for: tool)
            XCTAssertEqual(
                ShortcutManager.shared.getShortcut(for: tool),
                customKey,
                "\(tool.displayName) should accept custom shortcut '\(customKey)'"
            )
        }
        
        // Reset and verify defaults are restored
        ShortcutManager.shared.resetAllToDefault()
        XCTAssertEqual(ShortcutManager.shared.getShortcut(for: .pen), "q")
        XCTAssertEqual(ShortcutManager.shared.getShortcut(for: .line), "w")
        XCTAssertEqual(ShortcutManager.shared.getShortcut(for: .highlighter), "e")
    }
}
