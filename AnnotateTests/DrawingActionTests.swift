import XCTest

@testable import Annotate

@MainActor
final class DrawingActionTests: XCTestCase {

    func testAddPathAction() {
        let path = DrawingPath(
            points: [
                TimedPoint(point: .zero, timestamp: 0.0)
            ], color: .systemRed, lineWidth: 3.0)

        let action = DrawingAction.addPath(path)

        if case .addPath(let actionPath) = action {
            XCTAssertEqual(actionPath.points, path.points)
            XCTAssertEqual(actionPath.color, path.color)
            XCTAssertEqual(actionPath.lineWidth, path.lineWidth)
        } else {
            XCTFail("Wrong action type")
        }
    }

    func testAddArrowAction() {
        let arrow = Arrow(startPoint: .zero, endPoint: NSPoint(x: 10, y: 10), color: .blue, lineWidth: 3.0)
        let action = DrawingAction.addArrow(arrow)

        if case .addArrow(let actionArrow) = action {
            XCTAssertEqual(actionArrow.startPoint, arrow.startPoint)
            XCTAssertEqual(actionArrow.endPoint, arrow.endPoint)
            XCTAssertEqual(actionArrow.color, arrow.color)
            XCTAssertEqual(actionArrow.lineWidth, arrow.lineWidth)
        } else {
            XCTFail("Wrong action type")
        }
    }
    
    func testAddLineAction() {
        let line = Line(startPoint: .zero, endPoint: NSPoint(x: 10, y: 10), color: .red, lineWidth: 3.0)
        let action = DrawingAction.addLine(line)
        
        if case .addLine(let actionLine) = action {
            XCTAssertEqual(actionLine.startPoint, line.startPoint)
            XCTAssertEqual(actionLine.endPoint, line.endPoint)
            XCTAssertEqual(actionLine.color, line.color)
            XCTAssertEqual(actionLine.lineWidth, line.lineWidth)
        } else {
            XCTFail("Wrong action type")
        }
    }
    
    func testRemoveLineAction() {
        let line = Line(startPoint: .zero, endPoint: NSPoint(x: 20, y: 20), color: .green, lineWidth: 3.0)
        let action = DrawingAction.removeLine(line)
        
        if case .removeLine(let actionLine) = action {
            XCTAssertEqual(actionLine.startPoint, line.startPoint)
            XCTAssertEqual(actionLine.endPoint, line.endPoint)
            XCTAssertEqual(actionLine.color, line.color)
            XCTAssertEqual(actionLine.lineWidth, line.lineWidth)
        } else {
            XCTFail("Wrong action type")
        }
    }

    func testMoveTextAction() {
        let oldPosition = NSPoint(x: 0, y: 0)
        let newPosition = NSPoint(x: 100, y: 100)
        let index = 0

        let action = DrawingAction.moveText(index, oldPosition, newPosition)

        if case .moveText(let actionIndex, let actionOld, let actionNew) = action {
            XCTAssertEqual(actionIndex, index)
            XCTAssertEqual(actionOld, oldPosition)
            XCTAssertEqual(actionNew, newPosition)
        } else {
            XCTFail("Wrong action type")
        }
    }

    func testAddCounterAction() {
        let counter = CounterAnnotation(
            number: 1,
            position: NSPoint(x: 100, y: 100),
            color: .systemBlue
        )

        let action = DrawingAction.addCounter(counter)

        if case .addCounter(let actionCounter) = action {
            XCTAssertEqual(actionCounter.number, counter.number)
            XCTAssertEqual(actionCounter.position, counter.position)
            XCTAssertEqual(actionCounter.color, counter.color)
        } else {
            XCTFail("Wrong action type")
        }
    }

    func testRemoveCounterAction() {
        let counter = CounterAnnotation(
            number: 2,
            position: NSPoint(x: 200, y: 200),
            color: .systemGreen
        )

        let action = DrawingAction.removeCounter(counter)

        if case .removeCounter(let actionCounter) = action {
            XCTAssertEqual(actionCounter.number, counter.number)
            XCTAssertEqual(actionCounter.position, counter.position)
            XCTAssertEqual(actionCounter.color, counter.color)
        } else {
            XCTFail("Wrong action type")
        }
    }

    func testClearAllWithCounters() {
        let paths = [DrawingPath(points: [], color: .systemRed, lineWidth: 3.0)]
        let arrows = [Arrow(startPoint: .zero, endPoint: .zero, color: .blue, lineWidth: 3.0)]
        let lines = [Line(startPoint: .zero, endPoint: .zero, color: .red, lineWidth: 3.0)]
        let highlights = [DrawingPath(points: [], color: .yellow, lineWidth: 3.0)]
        let rectangles = [Rectangle(startPoint: .zero, endPoint: .zero, color: .green, lineWidth: 3.0)]
        let circles = [Circle(startPoint: .zero, endPoint: .zero, color: .purple, lineWidth: 3.0)]
        let texts = [TextAnnotation(text: "Test", position: .zero, color: .black, fontSize: 12)]
        let counters = [CounterAnnotation(number: 1, position: .zero, color: .orange)]

        let action = DrawingAction.clearAll(
            paths, arrows, lines, highlights, rectangles, circles, texts, counters)

        if case .clearAll(
            let actionPaths, let actionArrows, let actionLines, let actionHighlights,
            let actionRects, let actionCircles, let actionTexts, let actionCounters) = action
        {
            XCTAssertEqual(actionPaths, paths)
            XCTAssertEqual(actionArrows, arrows)
            XCTAssertEqual(actionLines, lines)
            XCTAssertEqual(actionHighlights, highlights)
            XCTAssertEqual(actionRects, rectangles)
            XCTAssertEqual(actionCircles, circles)
            XCTAssertEqual(actionTexts, texts)
            XCTAssertEqual(actionCounters, counters)
        } else {
            XCTFail("Wrong action type")
        }
    }

    func testClearAllAction() {
        let paths = [DrawingPath(points: [], color: .systemRed, lineWidth: 3.0)]
        let arrows = [Arrow(startPoint: .zero, endPoint: .zero, color: .blue, lineWidth: 3.0)]
        let lines = [Line(startPoint: .zero, endPoint: .zero, color: .red, lineWidth: 3.0)]
        let highlights = [DrawingPath(points: [], color: .yellow, lineWidth: 3.0)]
        let rectangles = [Rectangle(startPoint: .zero, endPoint: .zero, color: .green, lineWidth: 3.0)]
        let circles = [Circle(startPoint: .zero, endPoint: .zero, color: .purple, lineWidth: 3.0)]
        let texts = [TextAnnotation(text: "Test", position: .zero, color: .black, fontSize: 12)]
        let counters = [CounterAnnotation(number: 1, position: .zero, color: .black)]

        let action = DrawingAction.clearAll(
            paths, arrows, lines, highlights, rectangles, circles, texts, counters)

        if case .clearAll(
            let actionPaths, let actionArrows, let actionLines, let actionHighlights,
            let actionRects, let actionCircles, let actionTexts, let actionCounters) = action
        {
            XCTAssertEqual(actionPaths, paths)
            XCTAssertEqual(actionArrows, arrows)
            XCTAssertEqual(actionLines, lines)
            XCTAssertEqual(actionHighlights, highlights)
            XCTAssertEqual(actionRects, rectangles)
            XCTAssertEqual(actionCircles, circles)
            XCTAssertEqual(actionTexts, texts)
            XCTAssertEqual(actionCounters, counters)
        } else {
            XCTFail("Wrong action type")
        }
    }
}
