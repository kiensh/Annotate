import XCTest

@testable import Annotate

final class NSImageExtensionsTests: XCTestCase {
    func testCompositeImage() {
        // Create test images
        let bottomSize = NSSize(width: 100, height: 100)
        let bottomImage = NSImage(size: bottomSize)
        bottomImage.lockFocus()
        NSColor.systemRed.drawSwatch(in: NSRect(origin: .zero, size: bottomSize))
        bottomImage.unlockFocus()

        let topSize = NSSize(width: 50, height: 50)
        let topImage = NSImage(size: topSize)
        topImage.lockFocus()
        NSColor.blue.drawSwatch(in: NSRect(origin: .zero, size: topSize))
        topImage.unlockFocus()

        // Create composite
        let composite = NSImage.composite(bottomImage: bottomImage, topImage: topImage)

        // Verify composite properties
        XCTAssertEqual(composite.size, bottomSize)
        XCTAssertFalse(composite.isTemplate)

        // Convert to bitmap for pixel testing
        guard let cgImage = composite.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            XCTFail("Failed to create CGImage from composite")
            return
        }

        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)

        // Test center pixel (should be from top image)
        let centerPoint = NSPoint(x: bottomSize.width / 2, y: bottomSize.height / 2)
        let centerColor = bitmapRep.colorAt(x: Int(centerPoint.x), y: Int(centerPoint.y))
        XCTAssertNotNil(centerColor)

        // Test corner pixel (should be from bottom image)
        let cornerColor = bitmapRep.colorAt(x: 0, y: 0)
        XCTAssertNotNil(cornerColor)
    }
}
