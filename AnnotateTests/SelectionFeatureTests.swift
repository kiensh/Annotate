import XCTest

@testable import Annotate

@MainActor
final class SelectionFeatureTests: XCTestCase, Sendable {
    var overlayView: OverlayView!
    
    nonisolated override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            overlayView = OverlayView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        }
    }
    
    nonisolated override func tearDown() {
        MainActor.assumeIsolated {
            overlayView = nil
        }
        super.tearDown()
    }
    
    // MARK: - Basic Selection Tests
    
    func testSelectToolMode() {
        overlayView.currentTool = .select
        XCTAssertEqual(overlayView.currentTool, .select)
    }
    
    func testEmptySelectionInitially() {
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    func testSingleObjectSelection() {
        // Add a line
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        // Find object at point
        let foundObject = overlayView.findObjectAt(point: NSPoint(x: 150, y: 150))
        
        // Should find the line
        if case .line(let index) = foundObject {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Should have found line")
        }
    }
    
    func testMultipleObjectSelection() {
        // Add multiple objects
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        let circle = Circle(
            startPoint: NSPoint(x: 300, y: 300),
            endPoint: NSPoint(x: 400, y: 400),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.circles.append(circle)
        
        // Select both
        overlayView.selectedObjects = [.line(index: 0), .circle(index: 0)]
        
        XCTAssertEqual(overlayView.selectedObjects.count, 2)
        XCTAssertTrue(overlayView.selectedObjects.contains(.line(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.circle(index: 0)))
    }
    
    // MARK: - Hit Testing Tests
    
    func testHitTestLine() {
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        // Point on the line
        let onLine = overlayView.findObjectAt(point: NSPoint(x: 150, y: 150))
        XCTAssertNotEqual(onLine, .none)
        
        // Point far from line
        let offLine = overlayView.findObjectAt(point: NSPoint(x: 500, y: 500))
        XCTAssertEqual(offLine, .none)
    }
    
    func testHitTestRectangleEdgeOnly() {
        let rect = Rectangle(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.rectangles.append(rect)
        
        // Point on edge should hit
        let onEdge = overlayView.findObjectAt(point: NSPoint(x: 100, y: 150))
        XCTAssertNotEqual(onEdge, .none)
        
        // Point in center should NOT hit (edge-only selection)
        let inCenter = overlayView.findObjectAt(point: NSPoint(x: 150, y: 150))
        XCTAssertEqual(inCenter, .none)
    }
    
    func testHitTestCircleEdgeOnly() {
        let circle = Circle(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.circles.append(circle)
        
        // Point in center should NOT hit (edge-only selection)
        let inCenter = overlayView.findObjectAt(point: NSPoint(x: 150, y: 150))
        XCTAssertEqual(inCenter, .none)
    }
    
    func testHitTestText() {
        let textAnnotation = TextAnnotation(
            text: "Hello",
            position: NSPoint(x: 100, y: 100),
            color: .black,
            fontSize: 18
        )
        overlayView.textAnnotations.append(textAnnotation)
        
        // Point in text area should hit
        let inText = overlayView.findObjectAt(point: NSPoint(x: 110, y: 110))
        if case .text(let index) = inText {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Should have found text")
        }
    }
    
    func testHitTestCounter() {
        let counter = CounterAnnotation(
            number: 1,
            position: NSPoint(x: 100, y: 100),
            color: .red,
            creationTime: nil
        )
        overlayView.counterAnnotations.append(counter)
        
        // Point near counter should hit
        let nearCounter = overlayView.findObjectAt(point: NSPoint(x: 105, y: 105))
        if case .counter(let index) = nearCounter {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("Should have found counter")
        }
    }
    
    // MARK: - Z-Order Selection Tests
    
    func testZOrderSelectionLatestFirst() {
        // Add two overlapping lines
        let line1 = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 10.0,
            creationTime: nil
        )
        overlayView.lines.append(line1)
        
        let line2 = Line(
            startPoint: NSPoint(x: 110, y: 110),
            endPoint: NSPoint(x: 210, y: 210),
            color: .blue,
            lineWidth: 10.0,
            creationTime: nil
        )
        overlayView.lines.append(line2)
        
        // Click on overlapping area - should get the latest (line2)
        let found = overlayView.findObjectAt(point: NSPoint(x: 150, y: 150))
        if case .line(let index) = found {
            XCTAssertEqual(index, 1, "Should select the latest line (index 1)")
        } else {
            XCTFail("Should have found a line")
        }
    }
    
    // MARK: - Rectangle Selection Tests
    
    func testRectangleSelectionFindsObjects() {
        // Add objects at different positions
        let line = Line(
            startPoint: NSPoint(x: 50, y: 50),
            endPoint: NSPoint(x: 100, y: 100),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        let circle = Circle(
            startPoint: NSPoint(x: 200, y: 200),
            endPoint: NSPoint(x: 250, y: 250),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.circles.append(circle)
        
        // Rectangle that covers the line but not the circle
        let rect = NSRect(x: 40, y: 40, width: 80, height: 80)
        let foundObjects = overlayView.findObjectsInRect(rect)
        
        XCTAssertTrue(foundObjects.contains(.line(index: 0)))
        XCTAssertFalse(foundObjects.contains(.circle(index: 0)))
    }
    
    func testRectangleSelectionEmpty() {
        // Add a line
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        // Rectangle that doesn't cover anything
        let rect = NSRect(x: 300, y: 300, width: 50, height: 50)
        let foundObjects = overlayView.findObjectsInRect(rect)
        
        XCTAssertTrue(foundObjects.isEmpty)
    }
    
    // MARK: - Bounding Box Tests
    
    func testGetObjectBoundsLine() {
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        let bounds = overlayView.getObjectBounds(.line(index: 0))
        
        XCTAssertEqual(bounds.origin.x, 100)
        XCTAssertEqual(bounds.origin.y, 100)
        XCTAssertEqual(bounds.width, 100)
        XCTAssertEqual(bounds.height, 100)
    }
    
    func testGetObjectBoundsRectangle() {
        let rect = Rectangle(
            startPoint: NSPoint(x: 50, y: 50),
            endPoint: NSPoint(x: 150, y: 150),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.rectangles.append(rect)
        
        let bounds = overlayView.getObjectBounds(.rectangle(index: 0))
        
        XCTAssertEqual(bounds.origin.x, 50)
        XCTAssertEqual(bounds.origin.y, 50)
        XCTAssertEqual(bounds.width, 100)
        XCTAssertEqual(bounds.height, 100)
    }
    
    func testCalculateSelectionBoundingBoxSingleObject() {
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        overlayView.selectedObjects = [.line(index: 0)]
        
        let boundingBox = overlayView.calculateSelectionBoundingBox()
        
        // Should be the line bounds with 5pt padding
        XCTAssertEqual(boundingBox.origin.x, 95)
        XCTAssertEqual(boundingBox.origin.y, 95)
        XCTAssertEqual(boundingBox.width, 110)
        XCTAssertEqual(boundingBox.height, 110)
    }
    
    func testCalculateSelectionBoundingBoxMultipleObjects() {
        // Add two objects
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        let circle = Circle(
            startPoint: NSPoint(x: 300, y: 300),
            endPoint: NSPoint(x: 400, y: 400),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.circles.append(circle)
        
        overlayView.selectedObjects = [.line(index: 0), .circle(index: 0)]
        
        let boundingBox = overlayView.calculateSelectionBoundingBox()
        
        // Should encompass both objects with padding
        XCTAssertEqual(boundingBox.origin.x, 95)
        XCTAssertEqual(boundingBox.origin.y, 95)
        XCTAssertEqual(boundingBox.width, 310) // From 95 to 405
        XCTAssertEqual(boundingBox.height, 310)
    }
    
    func testIsPointInSelectionBoundingBox() {
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        overlayView.selectedObjects = [.line(index: 0)]
        
        // Point inside bounding box
        XCTAssertTrue(overlayView.isPointInSelectionBoundingBox(NSPoint(x: 150, y: 150)))
        
        // Point outside bounding box
        XCTAssertFalse(overlayView.isPointInSelectionBoundingBox(NSPoint(x: 300, y: 300)))
    }
    
    // MARK: - Object Movement Tests
    
    func testMoveSelectedObjects() {
        // Add a line
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        overlayView.selectedObjects = [.line(index: 0)]
        
        // Move by delta
        let delta = NSPoint(x: 50, y: 50)
        overlayView.moveSelectedObjects(by: delta)
        
        // Check line moved
        XCTAssertEqual(overlayView.lines[0].startPoint.x, 150)
        XCTAssertEqual(overlayView.lines[0].startPoint.y, 150)
        XCTAssertEqual(overlayView.lines[0].endPoint.x, 250)
        XCTAssertEqual(overlayView.lines[0].endPoint.y, 250)
    }
    
    func testMoveMultipleSelectedObjects() {
        // Add two objects
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        let circle = Circle(
            startPoint: NSPoint(x: 300, y: 300),
            endPoint: NSPoint(x: 400, y: 400),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.circles.append(circle)
        
        overlayView.selectedObjects = [.line(index: 0), .circle(index: 0)]
        
        // Move both
        let delta = NSPoint(x: 10, y: 20)
        overlayView.moveSelectedObjects(by: delta)
        
        // Check both moved
        XCTAssertEqual(overlayView.lines[0].startPoint.x, 110)
        XCTAssertEqual(overlayView.lines[0].startPoint.y, 120)
        XCTAssertEqual(overlayView.circles[0].startPoint.x, 310)
        XCTAssertEqual(overlayView.circles[0].startPoint.y, 320)
    }
    
    // MARK: - Deletion Tests
    
    func testDeleteSelectedObjects() {
        // Add multiple objects
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        let circle = Circle(
            startPoint: NSPoint(x: 300, y: 300),
            endPoint: NSPoint(x: 400, y: 400),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.circles.append(circle)
        
        overlayView.selectedObjects = [.line(index: 0), .circle(index: 0)]
        
        // Delete selected
        overlayView.deleteSelectedObjects()
        
        // Both should be deleted
        XCTAssertTrue(overlayView.lines.isEmpty)
        XCTAssertTrue(overlayView.circles.isEmpty)
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    func testDeleteLastItemInSelectMode() {
        // Add objects
        let line = Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        )
        overlayView.lines.append(line)
        
        overlayView.currentTool = .select
        overlayView.selectedObjects = [.line(index: 0)]
        
        // Call deleteLastItem (which should delete selected)
        overlayView.deleteLastItem()
        
        XCTAssertTrue(overlayView.lines.isEmpty)
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    // MARK: - Edge Cases
    
    func testEmptySelectionBoundingBox() {
        let boundingBox = overlayView.calculateSelectionBoundingBox()
        XCTAssertEqual(boundingBox, NSRect.zero)
    }
    
    func testMoveEmptySelection() {
        // Should not crash
        overlayView.moveSelectedObjects(by: NSPoint(x: 10, y: 10))
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    func testDeleteEmptySelection() {
        // Should not crash
        overlayView.deleteSelectedObjects()
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    func testFindObjectAtEmptyCanvas() {
        let found = overlayView.findObjectAt(point: NSPoint(x: 100, y: 100))
        XCTAssertEqual(found, .none)
    }
    
    func testRectangleSelectionEmptyCanvas() {
        let rect = NSRect(x: 0, y: 0, width: 100, height: 100)
        let found = overlayView.findObjectsInRect(rect)
        XCTAssertTrue(found.isEmpty)
    }
    
    // MARK: - Select All Tests
    
    func testSelectAllInSelectMode() {
        // Add various objects
        overlayView.arrows.append(Arrow(
            startPoint: NSPoint(x: 10, y: 10),
            endPoint: NSPoint(x: 50, y: 50),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.lines.append(Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.rectangles.append(Rectangle(
            startPoint: NSPoint(x: 300, y: 300),
            endPoint: NSPoint(x: 400, y: 400),
            color: .green,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.circles.append(Circle(
            startPoint: NSPoint(x: 500, y: 500),
            endPoint: NSPoint(x: 600, y: 600),
            color: .yellow,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.textAnnotations.append(TextAnnotation(
            text: "Test",
            position: NSPoint(x: 700, y: 700),
            color: .black,
            fontSize: 18
        ))
        
        // Switch to select mode
        overlayView.currentTool = .select
        
        // Call selectAllObjects
        overlayView.selectAllObjects()
        
        // Should have selected all 5 objects
        XCTAssertEqual(overlayView.selectedObjects.count, 5)
        XCTAssertTrue(overlayView.selectedObjects.contains(.arrow(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.line(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.rectangle(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.circle(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.text(index: 0)))
    }
    
    func testSelectAllNotInSelectMode() {
        // Add some objects
        overlayView.lines.append(Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        // In pen mode, not select mode
        overlayView.currentTool = .pen
        
        // Call selectAllObjects
        overlayView.selectAllObjects()
        
        // Should not select anything when not in select mode
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    func testSelectAllEmptyCanvas() {
        overlayView.currentTool = .select
        
        // Call selectAllObjects on empty canvas
        overlayView.selectAllObjects()
        
        // Should remain empty
        XCTAssertTrue(overlayView.selectedObjects.isEmpty)
    }
    
    func testSelectAllClearsPreviousSelection() {
        // Add objects
        overlayView.lines.append(Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.arrows.append(Arrow(
            startPoint: NSPoint(x: 10, y: 10),
            endPoint: NSPoint(x: 50, y: 50),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.currentTool = .select
        
        // Select just one object
        overlayView.selectedObjects = [.line(index: 0)]
        XCTAssertEqual(overlayView.selectedObjects.count, 1)
        
        // Call selectAllObjects
        overlayView.selectAllObjects()
        
        // Should now have all objects selected
        XCTAssertEqual(overlayView.selectedObjects.count, 2)
        XCTAssertTrue(overlayView.selectedObjects.contains(.line(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.arrow(index: 0)))
    }
    
    func testSelectAllWithAllObjectTypes() {
        overlayView.currentTool = .select
        
        // Add one of each type
        overlayView.paths.append(DrawingPath(
            points: [TimedPoint(point: NSPoint(x: 0, y: 0), timestamp: 0)],
            color: .red,
            lineWidth: 2.0
        ))
        
        overlayView.arrows.append(Arrow(
            startPoint: NSPoint(x: 10, y: 10),
            endPoint: NSPoint(x: 50, y: 50),
            color: .red,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.lines.append(Line(
            startPoint: NSPoint(x: 100, y: 100),
            endPoint: NSPoint(x: 200, y: 200),
            color: .blue,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.highlightPaths.append(DrawingPath(
            points: [TimedPoint(point: NSPoint(x: 150, y: 150), timestamp: 0)],
            color: .yellow,
            lineWidth: 20.0
        ))
        
        overlayView.rectangles.append(Rectangle(
            startPoint: NSPoint(x: 300, y: 300),
            endPoint: NSPoint(x: 400, y: 400),
            color: .green,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.circles.append(Circle(
            startPoint: NSPoint(x: 500, y: 500),
            endPoint: NSPoint(x: 600, y: 600),
            color: .yellow,
            lineWidth: 2.0,
            creationTime: nil
        ))
        
        overlayView.textAnnotations.append(TextAnnotation(
            text: "Test",
            position: NSPoint(x: 700, y: 700),
            color: .black,
            fontSize: 18
        ))
        
        overlayView.counterAnnotations.append(CounterAnnotation(
            number: 1,
            position: NSPoint(x: 800, y: 800),
            color: .red,
            creationTime: nil
        ))
        
        // Call selectAllObjects
        overlayView.selectAllObjects()
        
        // Should select all 8 objects (one of each type)
        XCTAssertEqual(overlayView.selectedObjects.count, 8)
        XCTAssertTrue(overlayView.selectedObjects.contains(.path(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.arrow(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.line(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.highlight(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.rectangle(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.circle(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.text(index: 0)))
        XCTAssertTrue(overlayView.selectedObjects.contains(.counter(index: 0)))
    }
}
