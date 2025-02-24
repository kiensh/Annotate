import XCTest

@testable import Annotate

final class OverlayViewTests: XCTestCase {

    var overlayView: OverlayView!

    override func setUp() {
        super.setUp()
        overlayView = OverlayView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
    }

    override func tearDown() {
        overlayView = nil
        super.tearDown()
    }

    func testOverlayViewInitialization() {
        XCTAssertEqual(overlayView.currentColor, .systemRed)
        XCTAssertEqual(overlayView.currentTool, .pen)
        XCTAssertTrue(overlayView.fadeMode)
        XCTAssertEqual(overlayView.fadeDuration, 1.25)

        // Test empty collections
        XCTAssertTrue(overlayView.paths.isEmpty)
        XCTAssertTrue(overlayView.arrows.isEmpty)
        XCTAssertTrue(overlayView.highlightPaths.isEmpty)
        XCTAssertTrue(overlayView.rectangles.isEmpty)
        XCTAssertTrue(overlayView.circles.isEmpty)
        XCTAssertTrue(overlayView.textAnnotations.isEmpty)

        // Test nil values
        XCTAssertNil(overlayView.currentPath)
        XCTAssertNil(overlayView.currentArrow)
        XCTAssertNil(overlayView.currentHighlight)
        XCTAssertNil(overlayView.currentRectangle)
        XCTAssertNil(overlayView.currentCircle)
        XCTAssertNil(overlayView.currentTextAnnotation)
    }

    func testToolSwitching() {
        // Test all tool types
        overlayView.currentTool = .pen
        XCTAssertEqual(overlayView.currentTool, .pen)

        overlayView.currentTool = .arrow
        XCTAssertEqual(overlayView.currentTool, .arrow)

        overlayView.currentTool = .highlighter
        XCTAssertEqual(overlayView.currentTool, .highlighter)

        overlayView.currentTool = .rectangle
        XCTAssertEqual(overlayView.currentTool, .rectangle)

        overlayView.currentTool = .circle
        XCTAssertEqual(overlayView.currentTool, .circle)

        overlayView.currentTool = .text
        XCTAssertEqual(overlayView.currentTool, .text)
    }

    func testClearAll() {
        // Add some test data
        overlayView.paths = [DrawingPath(points: [], color: .red)]
        overlayView.arrows = [Arrow(startPoint: .zero, endPoint: .zero, color: .blue)]
        overlayView.highlightPaths = [DrawingPath(points: [], color: .yellow)]
        overlayView.rectangles = [Rectangle(startPoint: .zero, endPoint: .zero, color: .green)]
        overlayView.circles = [Circle(startPoint: .zero, endPoint: .zero, color: .purple)]
        overlayView.textAnnotations = [
            TextAnnotation(text: "Test", position: .zero, color: .black, fontSize: 12)
        ]

        // Clear all
        overlayView.clearAll()

        // Verify everything is cleared
        XCTAssertTrue(overlayView.paths.isEmpty)
        XCTAssertTrue(overlayView.arrows.isEmpty)
        XCTAssertTrue(overlayView.highlightPaths.isEmpty)
        XCTAssertTrue(overlayView.rectangles.isEmpty)
        XCTAssertTrue(overlayView.circles.isEmpty)
        XCTAssertTrue(overlayView.textAnnotations.isEmpty)
    }
}
