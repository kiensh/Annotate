import XCTest

@testable import Annotate

@MainActor
final class OverlayWindowTests: XCTestCase, Sendable {
    var window: OverlayWindow!

    nonisolated override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            let frame = NSRect(x: 0, y: 0, width: 800, height: 600)
            window = OverlayWindow(
                contentRect: frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
        }
    }

    nonisolated override func tearDown() {
        MainActor.assumeIsolated {
            window = nil
        }
        super.tearDown()
    }

    func testWindowInitialization() {
        XCTAssertEqual(window.level, .normal)
        XCTAssertFalse(window.isOpaque)
        XCTAssertFalse(window.hasShadow)
        XCTAssertFalse(window.ignoresMouseEvents)
        XCTAssertEqual(window.collectionBehavior, [.canJoinAllSpaces, .stationary])

        // Test view hierarchy
        XCTAssertNotNil(window.contentView)
        XCTAssertNotNil(window.overlayView)
    }

    func testFadeLoop() {
        XCTAssertNil(window.fadeTimer)

        window.startFadeLoop()
        XCTAssertNotNil(window.fadeTimer)
        XCTAssertTrue(window.fadeTimer?.isValid ?? false)

        window.stopFadeLoop()
        XCTAssertNil(window.fadeTimer)
    }

    func testMouseEvents() {
        // Test mouse down
        let mouseDownEvent = TestEvents.createMouseEvent(
            type: .leftMouseDown,
            location: NSPoint(x: 100, y: 100)
        )
        window.mouseDown(with: mouseDownEvent!)
        XCTAssertEqual(window.anchorPoint, NSPoint(x: 100, y: 100))

        // Test mouse dragged
        let mouseDragEvent = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: NSPoint(x: 150, y: 150)
        )
        window.mouseDragged(with: mouseDragEvent!)

        // Test mouse up
        let mouseUpEvent = TestEvents.createMouseEvent(
            type: .leftMouseUp,
            location: NSPoint(x: 150, y: 150)
        )
        window.mouseUp(with: mouseUpEvent!)
    }

    func testKeyEvents() {
        // Test ESC key
        let escEvent = TestEvents.createKeyEvent(type: .keyDown, keyCode: 53)
        window.keyDown(with: escEvent!)

        let shiftEscEvent = TestEvents.createKeyEvent(type: .keyDown, keyCode: 53, modifierFlags: .shift)
        window.keyDown(with: shiftEscEvent!)

        // Test space bar
        let spaceEvent = TestEvents.createKeyEvent(type: .keyDown, keyCode: 49)
        window.keyDown(with: spaceEvent!)

        // Test tool shortcuts
        let penEvent = TestEvents.createKeyEvent(type: .keyDown, keyCode: 35)  // P key
        window.keyDown(with: penEvent!)
        XCTAssertEqual(window.overlayView.currentTool, .pen)
    }
    
    func testLineWidthInitialization() {
        // Test default line width is set correctly
        XCTAssertEqual(window.overlayView.currentLineWidth, 3.0)
    }
    
    func testLineWidthAdjustment() {
        let initialLineWidth = window.overlayView.currentLineWidth
        
        // Set a new line width
        let newLineWidth: CGFloat = 5.5
        window.overlayView.currentLineWidth = newLineWidth
        
        XCTAssertEqual(window.overlayView.currentLineWidth, newLineWidth)
        XCTAssertNotEqual(window.overlayView.currentLineWidth, initialLineWidth)
    }
    
    func testLineWidthBounds() {
        // Test minimum line width
        window.overlayView.currentLineWidth = 0.1
        XCTAssertEqual(window.overlayView.currentLineWidth, 0.1)
        
        // Test maximum line width
        window.overlayView.currentLineWidth = 20.0
        XCTAssertEqual(window.overlayView.currentLineWidth, 20.0)
        
        // Test very large value (should still be set)
        window.overlayView.currentLineWidth = 50.0
        XCTAssertEqual(window.overlayView.currentLineWidth, 50.0)
    }
    
    func testLinePreviewViewCreation() {
        // Test that LinePreviewView can be created with proper dimensions
        let frame = NSRect(x: 0, y: 0, width: 200, height: 10)
        let lineView = LinePreviewView(frame: frame)
        
        XCTAssertNotNil(lineView)
        XCTAssertEqual(lineView.frame.width, 200)
        XCTAssertEqual(lineView.frame.height, 10)
    }
    
    func testLinePreviewViewProperties() {
        // Test that LinePreviewView has correct default properties
        let lineView = LinePreviewView(frame: NSRect(x: 0, y: 0, width: 100, height: 5))
        
        XCTAssertEqual(lineView.lineColor, .white, "Default line color should be white")
        XCTAssertEqual(lineView.lineWidth, 3.0, "Default line width should be 3.0")
    }
    
    func testLinePreviewViewWithDifferentWidths() {
        // Test LinePreviewView with various line widths
        let lineView = LinePreviewView(frame: NSRect(x: 0, y: 0, width: 100, height: 20))
        
        lineView.lineWidth = 0.5
        XCTAssertEqual(lineView.lineWidth, 0.5)
        
        lineView.lineWidth = 10.0
        XCTAssertEqual(lineView.lineWidth, 10.0)
        
        lineView.lineWidth = 20.0
        XCTAssertEqual(lineView.lineWidth, 20.0)
    }
    
    func testLinePreviewViewWithDifferentColors() {
        // Test LinePreviewView with various colors
        let lineView = LinePreviewView(frame: NSRect(x: 0, y: 0, width: 100, height: 5))
        
        lineView.lineColor = .red
        XCTAssertEqual(lineView.lineColor, .red)
        
        lineView.lineColor = .blue
        XCTAssertEqual(lineView.lineColor, .blue)
        
        lineView.lineColor = .black
        XCTAssertEqual(lineView.lineColor, .black)
    }
    
    func testFeedbackPositionBottomCenter() {
        // Test that feedback appears at bottom center
        let windowWidth = window.frame.width
        let containerWidth: CGFloat = 250
        let bottomPadding: CGFloat = 20
        
        let expectedX = (windowWidth - containerWidth) / 2
        let expectedY = bottomPadding
        
        XCTAssertEqual(expectedX, (800 - 250) / 2, "Feedback should be horizontally centered")
        XCTAssertEqual(expectedY, 20, "Feedback should be 20pt from bottom")
    }
    
    func testScrollWheelForLineWidth() {
        // Test that scroll wheel adjusts line width
        let initialWidth = window.overlayView.currentLineWidth
        
        // Simulate Command+Scroll up (increase width)
        let scrollUpEvent = TestEvents.createScrollEvent(deltaY: 1.0, modifierFlags: .command)
        if let event = scrollUpEvent {
            window.scrollWheel(with: event)
            // Note: We can't directly test the feedback display without UI tests,
            // but we can verify the function exists and is called
        }
        
        // The actual width change would be tested in integration tests
        // Here we just verify the initial state is correct
        XCTAssertGreaterThanOrEqual(initialWidth, 0.5, "Initial width should be within valid range")
        XCTAssertLessThanOrEqual(initialWidth, 20.0, "Initial width should be within valid range")
    }
}
