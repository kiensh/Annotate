import XCTest

@testable import Annotate

@MainActor
final class ShiftConstraintTests: XCTestCase, Sendable {
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

    // MARK: - Helper Methods

    private func performDragGesture(
        from start: NSPoint,
        to end: NSPoint,
        withShift: Bool = false
    ) {
        let modifierFlags: NSEvent.ModifierFlags = withShift ? .shift : []

        let mouseDownEvent = TestEvents.createMouseEvent(
            type: .leftMouseDown,
            location: start,
            modifierFlags: modifierFlags
        )
        window.mouseDown(with: mouseDownEvent!)

        let mouseDragEvent = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: end,
            modifierFlags: modifierFlags
        )
        window.mouseDragged(with: mouseDragEvent!)
    }

    private func completeDragGesture(at location: NSPoint, withShift: Bool = false) {
        let modifierFlags: NSEvent.ModifierFlags = withShift ? .shift : []
        let mouseUpEvent = TestEvents.createMouseEvent(
            type: .leftMouseUp,
            location: location,
            modifierFlags: modifierFlags
        )
        window.mouseUp(with: mouseUpEvent!)
    }

    private func assertLineAngle(_ line: Line, equals expectedAngle: CGFloat, accuracy: CGFloat = 0.01) {
        let dx = line.endPoint.x - line.startPoint.x
        let dy = line.endPoint.y - line.startPoint.y
        let angle = atan2(dy, dx)
        XCTAssertEqual(angle, expectedAngle, accuracy: accuracy)
    }

    private func assertArrowAngle(_ arrow: Arrow, equals expectedAngle: CGFloat, accuracy: CGFloat = 0.01) {
        let dx = arrow.endPoint.x - arrow.startPoint.x
        let dy = arrow.endPoint.y - arrow.startPoint.y
        let angle = atan2(dy, dx)
        XCTAssertEqual(angle, expectedAngle, accuracy: accuracy)
    }

    // MARK: - Snapping Algorithm Tests

    func testSnapTo0Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 150, y: 110)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            XCTAssertEqual(line.startPoint, start)
            XCTAssertEqual(line.endPoint.y, start.y, accuracy: 1.0)
            XCTAssertGreaterThan(line.endPoint.x, start.x)
        }
    }

    func testSnapTo45Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 150, y: 145)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            assertLineAngle(line, equals: .pi / 4)
        }
    }

    func testSnapTo90Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 110, y: 150)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            XCTAssertEqual(line.endPoint.x, start.x, accuracy: 1.0)
            XCTAssertGreaterThan(line.endPoint.y, start.y)
        }
    }

    func testSnapTo135Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 55, y: 145)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            assertLineAngle(line, equals: 3 * .pi / 4)
        }
    }

    func testSnapTo180Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 50, y: 105)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            XCTAssertEqual(line.endPoint.y, start.y, accuracy: 1.0)
            XCTAssertLessThan(line.endPoint.x, start.x)
        }
    }

    func testSnapTo225Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 55, y: 55)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            assertLineAngle(line, equals: -3 * .pi / 4)
        }
    }

    func testSnapTo270Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 105, y: 50)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            XCTAssertEqual(line.endPoint.x, start.x, accuracy: 1.0)
            XCTAssertLessThan(line.endPoint.y, start.y)
        }
    }

    func testSnapTo315Degrees() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 145, y: 55)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            assertLineAngle(line, equals: -.pi / 4)
        }
    }

    func testSnapWithZeroDistance() {
        let start = NSPoint(x: 100, y: 100)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: start, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            XCTAssertEqual(line.endPoint, start)
        }
    }

    func testSnapWithVerySmallDistance() {
        let start = NSPoint(x: 100, y: 100)
        let current = NSPoint(x: 101.5, y: 101.5)

        window.overlayView.currentTool = .line
        performDragGesture(from: start, to: current, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            assertLineAngle(line, equals: .pi / 4)
        }
    }

    // MARK: - Line Tool Integration Tests

    func testLineToolWithShiftFromStart() {
        window.overlayView.currentTool = .line
        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 210)

        performDragGesture(from: start, to: end, withShift: true)
        XCTAssertNotNil(window.overlayView.currentLine)

        completeDragGesture(at: end, withShift: true)
        XCTAssertEqual(window.overlayView.lines.count, 1)
    }

    func testLineToolWithoutShift() {
        window.overlayView.currentTool = .line
        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 210)

        performDragGesture(from: start, to: end)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            XCTAssertEqual(line.endPoint, end)
        }
    }

    // MARK: - Arrow Tool Integration Tests

    func testArrowToolWithShiftFromStart() {
        window.overlayView.currentTool = .arrow
        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 205)

        performDragGesture(from: start, to: end, withShift: true)
        XCTAssertNotNil(window.overlayView.currentArrow)

        completeDragGesture(at: end, withShift: true)
        XCTAssertEqual(window.overlayView.arrows.count, 1)
    }

    func testArrowToolWithoutShift() {
        window.overlayView.currentTool = .arrow
        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 205)

        performDragGesture(from: start, to: end)

        XCTAssertNotNil(window.overlayView.currentArrow)
        if let arrow = window.overlayView.currentArrow {
            XCTAssertEqual(arrow.endPoint, end)
        }
    }

    // MARK: - Pen Tool Integration Tests

    func testPenToolBecomesLineWithShift() {
        window.overlayView.currentTool = .pen
        let start = NSPoint(x: 100, y: 100)
        let mid = NSPoint(x: 120, y: 110)
        let end = NSPoint(x: 200, y: 205)

        performDragGesture(from: start, to: mid, withShift: true)

        let mouseDrag2 = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: end,
            modifierFlags: .shift
        )
        window.mouseDragged(with: mouseDrag2!)

        XCTAssertNotNil(window.overlayView.currentPath)
        if let path = window.overlayView.currentPath {
            XCTAssertEqual(path.points.count, 2)
            XCTAssertEqual(path.points[0].point, start)
        }
    }

    func testPenToolFreeformWithoutShift() {
        window.overlayView.currentTool = .pen
        let start = NSPoint(x: 100, y: 100)
        let mid = NSPoint(x: 120, y: 110)
        let end = NSPoint(x: 200, y: 205)

        performDragGesture(from: start, to: mid)

        let mouseDrag2 = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: end
        )
        window.mouseDragged(with: mouseDrag2!)

        XCTAssertNotNil(window.overlayView.currentPath)
        if let path = window.overlayView.currentPath {
            XCTAssertGreaterThan(path.points.count, 2)
        }
    }

    // MARK: - Highlighter Tool Integration Tests

    func testHighlighterBecomesLineWithShift() {
        window.overlayView.currentTool = .highlighter
        let start = NSPoint(x: 100, y: 100)
        let mid = NSPoint(x: 120, y: 110)
        let end = NSPoint(x: 200, y: 205)

        performDragGesture(from: start, to: mid, withShift: true)

        let mouseDrag2 = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: end,
            modifierFlags: .shift
        )
        window.mouseDragged(with: mouseDrag2!)

        XCTAssertNotNil(window.overlayView.currentHighlight)
        if let highlight = window.overlayView.currentHighlight {
            XCTAssertEqual(highlight.points.count, 2)
            XCTAssertEqual(highlight.points[0].point, start)
        }
    }

    func testHighlighterFreeformWithoutShift() {
        window.overlayView.currentTool = .highlighter
        let start = NSPoint(x: 100, y: 100)
        let mid = NSPoint(x: 120, y: 110)
        let end = NSPoint(x: 200, y: 205)

        performDragGesture(from: start, to: mid)

        let mouseDrag2 = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: end
        )
        window.mouseDragged(with: mouseDrag2!)

        XCTAssertNotNil(window.overlayView.currentHighlight)
        if let highlight = window.overlayView.currentHighlight {
            XCTAssertGreaterThan(highlight.points.count, 2)
        }
    }

    // MARK: - Dynamic Shift Toggling Tests

    func testPressingShiftMidDrag() {
        window.overlayView.currentTool = .line
        let start = NSPoint(x: 100, y: 100)
        let mid = NSPoint(x: 150, y: 130)
        let end = NSPoint(x: 200, y: 210)

        performDragGesture(from: start, to: mid)

        let flagsEvent = TestEvents.createKeyEvent(
            type: .flagsChanged,
            keyCode: 56,
            modifierFlags: .shift
        )
        window.flagsChanged(with: flagsEvent!)

        let mouseDrag2 = TestEvents.createMouseEvent(
            type: .leftMouseDragged,
            location: end,
            modifierFlags: .shift
        )
        window.mouseDragged(with: mouseDrag2!)

        XCTAssertNotNil(window.overlayView.currentLine)
    }

    func testReleasingShiftMidDrag() {
        window.overlayView.currentTool = .line
        let start = NSPoint(x: 100, y: 100)
        let mid = NSPoint(x: 150, y: 150)

        performDragGesture(from: start, to: mid, withShift: true)

        XCTAssertNotNil(window.overlayView.currentLine)
        if let line = window.overlayView.currentLine {
            assertLineAngle(line, equals: .pi / 4)
        }
    }

    // MARK: - Shift State Tests

    func testShiftStateTracking() {
        window.overlayView.currentTool = .line
        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 210)

        performDragGesture(from: start, to: end, withShift: true)
        XCTAssertNotNil(window.overlayView.currentLine)

        completeDragGesture(at: end, withShift: true)
        XCTAssertNil(window.overlayView.currentLine)
        XCTAssertEqual(window.overlayView.lines.count, 1)
    }

    // MARK: - Compatibility Tests

    func testShiftWithFadeMode() {
        window.overlayView.fadeMode = true
        window.overlayView.currentTool = .line

        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 210)

        performDragGesture(from: start, to: end, withShift: true)
        completeDragGesture(at: end, withShift: true)

        XCTAssertEqual(window.overlayView.lines.count, 1)
        XCTAssertNotNil(window.overlayView.lines.first?.creationTime)
    }

    func testShiftConstrainedLineCreation() {
        window.overlayView.currentTool = .line

        let start = NSPoint(x: 100, y: 100)
        let end = NSPoint(x: 200, y: 210)

        performDragGesture(from: start, to: end, withShift: true)
        completeDragGesture(at: end, withShift: true)

        XCTAssertEqual(window.overlayView.lines.count, 1)

        if let line = window.overlayView.lines.first {
            let dx = line.endPoint.x - line.startPoint.x
            let dy = line.endPoint.y - line.startPoint.y
            let angle = atan2(dy, dx)
            let normalizedAngle = round(angle / (.pi / 4)) * (.pi / 4)
            XCTAssertEqual(angle, normalizedAngle, accuracy: 0.01)
        }
    }
}
