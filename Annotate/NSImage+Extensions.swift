import SwiftUI

extension NSImage {
    /// Creates a new image by layering two images on top of each other.
    /// - Parameters:
    ///   - bottomImage: The image to be placed at the bottom.
    ///   - topImage: The image to be placed on top of the bottom image.
    /// - Returns: A new composite `NSImage`.
    static func composite(bottomImage: NSImage, topImage: NSImage) -> NSImage {
        let size = bottomImage.size
        let compositeImage = NSImage(size: size)
        compositeImage.lockFocus()

        // Draw the bottom image (colored circle)
        bottomImage.draw(
            in: NSRect(origin: .zero, size: size),
            from: NSRect(origin: .zero, size: size),
            operation: .sourceOver,
            fraction: 1.0)

        // Draw the top image (pencil) centered
        let topSize = topImage.size
        let topOrigin = NSPoint(
            x: (size.width - topSize.width) / 2,
            y: (size.height - topSize.height) / 2)
        topImage.draw(
            in: NSRect(origin: topOrigin, size: topSize),
            from: NSRect(origin: .zero, size: topSize),
            operation: .sourceOver,
            fraction: 1.0)

        compositeImage.unlockFocus()
        compositeImage.isTemplate = false

        return compositeImage
    }
}
