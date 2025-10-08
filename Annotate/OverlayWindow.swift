import Cocoa

class OverlayWindow: NSWindow {
    var overlayView: OverlayView!
    var boardView: BoardView!

    var anchorPoint: NSPoint = .zero
    private var isOptionCurrentlyPressed = false
    private var wasOptionPressedOnMouseDown = false
    private var isCenterModeActive = false

    var fadeTimer: Timer?
    let fadeInterval: TimeInterval = 1.0 / 60.0
    
    // Track the current feedback view to remove it when a new one appears
    private var currentFeedbackView: NSView?
    private var feedbackRemovalTask: DispatchWorkItem?

    var currentColor: NSColor {
        get { overlayView.currentColor }
        set {
            overlayView.currentColor = newValue
            overlayView.needsDisplay = true
        }
    }

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        let windowRect = NSRect(
            x: contentRect.origin.x,
            y: contentRect.origin.y,
            width: contentRect.width,
            height: contentRect.height
        )

        super.init(
            contentRect: windowRect,
            styleMask: style,
            backing: backingStoreType,
            defer: flag)

        self.level = .normal
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        self.setFrame(windowRect, display: true)

        let containerView = NSView(frame: NSRect(origin: .zero, size: windowRect.size))

        let boardFrame = NSRect(
            x: 0,
            y: 0,
            width: windowRect.width,
            height: windowRect.height
        )
        boardView = BoardView(frame: boardFrame)
        boardView.isHidden = !BoardManager.shared.isEnabled
        containerView.addSubview(boardView)

        overlayView = OverlayView(frame: containerView.bounds)
        overlayView.wantsLayer = true
        overlayView.layer?.opacity = 0.9
        containerView.addSubview(overlayView)

        self.contentView = containerView
    }

    func startFadeLoop() {
        guard fadeTimer == nil else { return }
        fadeTimer = Timer.scheduledTimer(
            timeInterval: fadeInterval,
            target: self,
            selector: #selector(updateFade),
            userInfo: nil,
            repeats: true
        )
    }

    func stopFadeLoop() {
        fadeTimer?.invalidate()
        fadeTimer = nil
    }

    @objc func updateFade() {
        overlayView.needsDisplay = true

        // Stop the loop if nothing is actively fading
        if !overlayView.isAnythingFading() {
            stopFadeLoop()
        }
    }

    override var canBecomeKey: Bool { true }

    override func mouseDown(with event: NSEvent) {
        let startPoint = event.locationInWindow
        anchorPoint = startPoint
        wasOptionPressedOnMouseDown = event.modifierFlags.contains(.option)
        isCenterModeActive = wasOptionPressedOnMouseDown
        let clickCount = event.clickCount

        if let activeTextField = overlayView.activeTextField {
            overlayView.finalizeTextAnnotation(activeTextField)
        }

        if overlayView.currentTool == .counter {
            let counterAnnotation = CounterAnnotation(
                number: overlayView.nextCounterNumber,
                position: startPoint,
                color: currentColor,
                creationTime: CACurrentMediaTime()
            )

            overlayView.registerUndo(action: .addCounter(counterAnnotation))
            overlayView.counterAnnotations.append(counterAnnotation)
            overlayView.nextCounterNumber += 1
            overlayView.needsDisplay = true

            if overlayView.fadeMode {
                startFadeLoop()
            }
            return
        }

        if overlayView.currentTool == .text {
            for (index, annotation) in overlayView.textAnnotations.enumerated() {
                let textRect = getTextRect(for: annotation)
                if textRect.contains(startPoint) {
                    if clickCount == 1 {
                        // Single click - prepare for dragging
                        overlayView.draggedTextAnnotationIndex = index
                        overlayView.dragOffset = NSPoint(
                            x: startPoint.x - annotation.position.x,
                            y: startPoint.y - annotation.position.y
                        )
                        overlayView.originalTextPosition = annotation.position
                    } else if clickCount == 2 {
                        // Double click - edit text
                        overlayView.editingTextAnnotationIndex = index
                        let existingAnnotation = overlayView.textAnnotations[index]

                        let attributes: [NSAttributedString.Key: Any] = [
                            .font: NSFont.systemFont(ofSize: 18)
                        ]
                        let size = existingAnnotation.text.size(withAttributes: attributes)

                        overlayView.createTextField(
                            at: existingAnnotation.position,
                            withText: existingAnnotation.text,
                            width: max(300, size.width + 20)
                        )
                    }
                    return
                }
            }

            // If we didn't click on existing text, create new one
            overlayView.currentTextAnnotation = TextAnnotation(
                text: "",
                position: startPoint,
                color: currentColor,
                fontSize: 18
            )
            overlayView.createTextField(at: startPoint)
        }

        switch overlayView.currentTool {
        case .pen:
            let t = CACurrentMediaTime()
            overlayView.currentPath = DrawingPath(
                points: [TimedPoint(point: startPoint, timestamp: t)],
                color: currentColor,
                lineWidth: overlayView.currentLineWidth)
        case .arrow:
            overlayView.currentArrow = Arrow(
                startPoint: startPoint, endPoint: startPoint, color: currentColor, lineWidth: overlayView.currentLineWidth, creationTime: nil)
        case .line:
            overlayView.currentLine = Line(
                startPoint: startPoint, endPoint: startPoint, color: currentColor, lineWidth: overlayView.currentLineWidth, creationTime: nil)
        case .highlighter:
            let t = CACurrentMediaTime()
            overlayView.currentHighlight = DrawingPath(
                points: [TimedPoint(point: startPoint, timestamp: t)],
                color: currentColor.withAlphaComponent(0.3),
                lineWidth: overlayView.currentLineWidth)
        case .rectangle:
            overlayView.currentRectangle = Rectangle(
                startPoint: startPoint, endPoint: startPoint, color: overlayView.currentColor, lineWidth: overlayView.currentLineWidth, creationTime: nil)
        case .circle:
            overlayView.currentCircle = Circle(
                startPoint: startPoint, endPoint: startPoint, color: overlayView.currentColor, lineWidth: overlayView.currentLineWidth, creationTime: nil)
        case .text:
            break
        case .counter:
            break
        }
        overlayView.needsDisplay = true
    }

    private func getTextRect(for annotation: TextAnnotation) -> NSRect {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: annotation.fontSize)
        ]
        let size = annotation.text.size(withAttributes: attributes)
        return NSRect(
            x: annotation.position.x,
            y: annotation.position.y,
            width: size.width + 20,
            height: size.height + 10
        )
    }

    override func mouseDragged(with event: NSEvent) {
        overlayView.needsDisplay = true
        let currentPoint = event.locationInWindow

        if let draggedIndex = overlayView.draggedTextAnnotationIndex,
            let dragOffset = overlayView.dragOffset
        {
            // Update the position of the dragged text annotation
            let newPosition = NSPoint(
                x: currentPoint.x - dragOffset.x,
                y: currentPoint.y - dragOffset.y
            )
            overlayView.textAnnotations[draggedIndex].position = newPosition
            overlayView.needsDisplay = true
            return
        }

        switch overlayView.currentTool {
        case .pen:
            let t = CACurrentMediaTime()
            overlayView.currentPath?.points.append(TimedPoint(point: currentPoint, timestamp: t))
        case .arrow:
            overlayView.currentArrow?.endPoint = currentPoint
        case .line:
            overlayView.currentLine?.endPoint = currentPoint
        case .highlighter:
            let t = CACurrentMediaTime()
            overlayView.currentHighlight?.points.append(
                TimedPoint(point: currentPoint, timestamp: t))
        case .rectangle:
            if isCenterModeActive {
                let dx = currentPoint.x - anchorPoint.x
                let dy = currentPoint.y - anchorPoint.y
                let newStart = NSPoint(x: anchorPoint.x - dx, y: anchorPoint.y - dy)
                let newEnd = NSPoint(x: anchorPoint.x + dx, y: anchorPoint.y + dy)
                overlayView.currentRectangle?.startPoint = newStart
                overlayView.currentRectangle?.endPoint = newEnd
            } else {
                overlayView.currentRectangle?.endPoint = currentPoint
            }
        case .circle:
            if isCenterModeActive {
                let dx = currentPoint.x - anchorPoint.x
                let dy = currentPoint.y - anchorPoint.y
                let newStart = NSPoint(x: anchorPoint.x - dx, y: anchorPoint.y - dy)
                let newEnd = NSPoint(x: anchorPoint.x + dx, y: anchorPoint.y + dy)
                overlayView.currentCircle?.startPoint = newStart
                overlayView.currentCircle?.endPoint = newEnd
            } else {
                overlayView.currentCircle?.endPoint = currentPoint
            }
        case .text:
            break
        case .counter:
            break
        }
        overlayView.needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        overlayView.needsDisplay = true

        if let draggedIndex = overlayView.draggedTextAnnotationIndex {
            let oldPosition =
                overlayView.originalTextPosition
                ?? overlayView.textAnnotations[draggedIndex].position
            let newPosition = overlayView.textAnnotations[draggedIndex].position
            if newPosition != oldPosition {
                overlayView.registerUndo(action: .moveText(draggedIndex, oldPosition, newPosition))
            }
            overlayView.draggedTextAnnotationIndex = nil
            overlayView.originalTextPosition = nil
            overlayView.dragOffset = nil
        }

        switch overlayView.currentTool {
        case .pen:
            if var currentPath = overlayView.currentPath {
                let finalTime = CACurrentMediaTime()
                // Find the oldest point’s timestamp
                guard let minTimestamp = currentPath.points.map({ $0.timestamp }).min() else {
                    return
                }
                var updatedPoints = currentPath.points
                // Shift each point so that the oldest is effectively 0 at mouseUp
                let offset = finalTime - minTimestamp
                for i in 0..<updatedPoints.count {
                    updatedPoints[i].timestamp += offset
                }
                currentPath.points = updatedPoints
                overlayView.registerUndo(action: .addPath(currentPath))
                overlayView.paths.append(currentPath)
                overlayView.currentPath = nil
            }
        case .arrow:
            if var currentArrow = overlayView.currentArrow {
                currentArrow.creationTime = CACurrentMediaTime()
                overlayView.registerUndo(action: .addArrow(currentArrow))
                overlayView.arrows.append(currentArrow)
                overlayView.currentArrow = nil
            }
        case .line:
            if var currentLine = overlayView.currentLine {
                currentLine.creationTime = CACurrentMediaTime()
                overlayView.registerUndo(action: .addLine(currentLine))
                overlayView.lines.append(currentLine)
                overlayView.currentLine = nil
            }
        case .highlighter:
            if var currentHighlight = overlayView.currentHighlight {
                let finalTime = CACurrentMediaTime()
                // Find the oldest point’s timestamp
                guard let minTimestamp = currentHighlight.points.map({ $0.timestamp }).min() else {
                    return
                }
                var updatedPoints = currentHighlight.points
                // Shift each point so that the oldest is effectively 0 at mouseUp
                let offset = finalTime - minTimestamp
                for i in 0..<updatedPoints.count {
                    updatedPoints[i].timestamp += offset
                }
                currentHighlight.points = updatedPoints
                overlayView.registerUndo(action: .addHighlight(currentHighlight))
                overlayView.highlightPaths.append(currentHighlight)
                overlayView.currentHighlight = nil
            }
        case .rectangle:
            if var currentRectangle = overlayView.currentRectangle {
                currentRectangle.creationTime = CACurrentMediaTime()
                overlayView.registerUndo(action: .addRectangle(currentRectangle))
                overlayView.rectangles.append(currentRectangle)
                overlayView.currentRectangle = nil
            }
        case .circle:
            if var currentCircle = overlayView.currentCircle {
                currentCircle.creationTime = CACurrentMediaTime()
                overlayView.registerUndo(action: .addCircle(currentCircle))
                overlayView.circles.append(currentCircle)
                overlayView.currentCircle = nil
            }
        case .text:
            break
        case .counter:
            break
        }
        overlayView.needsDisplay = true
        wasOptionPressedOnMouseDown = false
        isCenterModeActive = false

        if overlayView.fadeMode {
            startFadeLoop()
        }
    }

    override func keyDown(with event: NSEvent) {
        let cmdPressed = event.modifierFlags.contains(.command)
        let key = event.characters?.lowercased() ?? ""

        // Handle single-key shortcuts if no modifiers are pressed
        if !cmdPressed
            && event.modifierFlags.intersection([.command, .option, .control, .shift]).isEmpty
        {
            switch key {
            case ShortcutManager.shared.getShortcut(for: .pen):
                AppDelegate.shared?.enablePenMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .arrow):
                AppDelegate.shared?.enableArrowMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .line):
                AppDelegate.shared?.enableLineMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .highlighter):
                AppDelegate.shared?.enableHighlighterMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .rectangle):
                AppDelegate.shared?.enableRectangleMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .circle):
                AppDelegate.shared?.enableCircleMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .counter):
                AppDelegate.shared?.enableCounterMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .text):
                AppDelegate.shared?.enableTextMode(NSMenuItem())
                return
            case ShortcutManager.shared.getShortcut(for: .colorPicker):
                AppDelegate.shared?.showColorPicker(nil)
                return
            case ShortcutManager.shared.getShortcut(for: .lineWidthPicker):
                AppDelegate.shared?.showLineWidthPicker(nil)
                return
            case ShortcutManager.shared.getShortcut(for: .toggleBoard):
                AppDelegate.shared?.toggleBoardVisibility(nil)
                return
            default:
                break
            }
        }

        switch event.keyCode {
        case 53:  // ESC key
            if event.modifierFlags.contains(.shift) {
                AppDelegate.shared?.closeOverlayAndEnableAlwaysOn()
            } else {
                AppDelegate.shared?.toggleOverlay()
            }
        case 51:  // Delete/Backspace key
            if event.modifierFlags.contains(.option) {
                overlayView.clearAll()
            } else {
                overlayView.deleteLastItem()
            }
        case 49:  // Spacebar - toggle drawing mode
            AppDelegate.shared?.toggleFadeMode(NSMenuItem())
        case 13:  // 'w' key
            if cmdPressed { AppDelegate.shared?.closeOverlay() }
        case 6:  // 'z' key
            if cmdPressed {
                if event.modifierFlags.contains(.shift) {
                    overlayView.redo()
                } else {
                    overlayView.undo()
                }
            }
        default:
            super.keyDown(with: event)
        }
    }

    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
        let optionPressed = event.modifierFlags.contains(.option)

        if !wasOptionPressedOnMouseDown {
            if !isOptionCurrentlyPressed && optionPressed {
                recenterAnchorForCurrentShape()
                isCenterModeActive = true
            } else if isOptionCurrentlyPressed && !optionPressed {
                isCenterModeActive = false
            }
        }

        isOptionCurrentlyPressed = optionPressed
    }

    private func recenterAnchorForCurrentShape() {
        if let rect = overlayView.currentRectangle {
            let boundingRect = NSRect(
                x: min(rect.startPoint.x, rect.endPoint.x),
                y: min(rect.startPoint.y, rect.endPoint.y),
                width: abs(rect.endPoint.x - rect.startPoint.x),
                height: abs(rect.endPoint.y - rect.startPoint.y)
            )
            anchorPoint = NSPoint(x: boundingRect.midX, y: boundingRect.midY)
        } else if let circle = overlayView.currentCircle {
            let boundingRect = NSRect(
                x: min(circle.startPoint.x, circle.endPoint.x),
                y: min(circle.startPoint.y, circle.endPoint.y),
                width: abs(circle.endPoint.x - circle.startPoint.x),
                height: abs(circle.endPoint.y - circle.startPoint.y)
            )
            anchorPoint = NSPoint(x: boundingRect.midX, y: boundingRect.midY)
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        // Check if Command key is pressed
        let cmdPressed = event.modifierFlags.contains(.command)
        
        if cmdPressed {
            scrollWheelForLineWidth(with: event)
        } else {
            // Default scroll behavior
            super.scrollWheel(with: event)
        }
    }
    
    private func scrollWheelForLineWidth(with event: NSEvent) {
        // Adjust line width with Command + Scroll
        let minLineWidth: CGFloat = 0.5
        let maxLineWidth: CGFloat = 20.0
        let ratio: CGFloat = 0.25
        
        // Get scroll delta (negative means scroll up, positive means scroll down)
        let scrollDelta = event.scrollingDeltaY
        
        // Determine direction and amount
        let increment: CGFloat = scrollDelta > 0 ? ratio : -ratio
        
        // Get current line width
        let currentWidth = overlayView.currentLineWidth
        
        // Calculate new width
        var newWidth = currentWidth + increment
        
        // Round to nearest ratio increment
        newWidth = round(newWidth / ratio) * ratio
        
        // Clamp to min/max
        newWidth = max(minLineWidth, min(maxLineWidth, newWidth))
        
        // Only update if value changed
        if newWidth != currentWidth {
            // Update the line width globally
            overlayView.currentLineWidth = newWidth
            
            // Save to UserDefaults
            UserDefaults.standard.set(Double(newWidth), forKey: UserDefaults.lineWidthKey)
            
            // Apply to all overlay windows
            AppDelegate.shared?.overlayWindows.values.forEach { window in
                window.overlayView.currentLineWidth = newWidth
            }
            
            // Show visual feedback
            showLineWidthFeedback(newWidth)
        }
    }
    
    private func showLineWidthFeedback(_ width: CGFloat) {
        let text = String(format: "Line Width: %.2f px", width)
        showFeedback(text, borderColor: overlayView.currentColor, borderWidth: width)
    }
    
    /// Shows a feedback message at the bottom center of the screen
    /// - Parameters:
    ///   - text: The message to display
    ///   - duration: How long to show the message (default: 1.5 seconds)
    ///   - fadeOutDuration: How long the fade out animation takes (default: 0.5 seconds)
    ///   - borderColor: Optional border color (default: nil for no border)
    ///   - borderWidth: Optional border width (default: nil for no border)
    private func showFeedback(
        _ text: String,
        duration: TimeInterval = 1.5,
        fadeOutDuration: TimeInterval = 0.5,
        borderColor: NSColor? = nil,
        borderWidth: CGFloat? = nil
    ) {
        removePreviousFeedback()
        
        let containerView = createFeedbackContainer(
            text: text,
            lineColor: borderColor,
            lineWidth: borderWidth
        )
        
        overlayView.addSubview(containerView)
        currentFeedbackView = containerView
        
        scheduleFeedbackRemoval(
            containerView: containerView,
            duration: duration,
            fadeOutDuration: fadeOutDuration
        )
    }
    
    private func removePreviousFeedback() {
        feedbackRemovalTask?.cancel()
        
        if let previousView = currentFeedbackView {
            previousView.removeFromSuperview()
            currentFeedbackView = nil
        }
    }
    
    private func createFeedbackContainer(
        text: String,
        lineColor: NSColor?,
        lineWidth: CGFloat?
    ) -> NSView {
        let containerWidth: CGFloat = 250
        let containerHeight: CGFloat = 80
        let bottomPadding: CGFloat = 20
        let extraLinePadding = lineWidth != nil ? max(0, lineWidth! / 2) : 0
        
        let containerView = NSView(frame: NSRect(
            x: (frame.width - containerWidth) / 2,
            y: bottomPadding + extraLinePadding,
            width: containerWidth,
            height: containerHeight
        ))
        
        configureFeedbackContainerStyle(containerView, lineColor: lineColor)
        
        let feedbackLabel = createFeedbackLabel(
            text: text,
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            backgroundColor: containerView.layer?.backgroundColor
        )
        containerView.addSubview(feedbackLabel)
        
        if let lineColor = lineColor, let lineWidth = lineWidth {
            let lineView = createLinePreview(
                lineColor: lineColor,
                lineWidth: lineWidth,
                containerWidth: containerWidth
            )
            containerView.addSubview(lineView)
        }
        
        return containerView
    }
    
    private func configureFeedbackContainerStyle(_ containerView: NSView, lineColor: NSColor?) {
        containerView.wantsLayer = true
        
        let backgroundColor: NSColor
        if let lineColor = lineColor {
            backgroundColor = lineColor.contrastingColor().withAlphaComponent(0.75)
        } else {
            backgroundColor = NSColor.black.withAlphaComponent(0.75)
        }
        
        containerView.layer?.backgroundColor = backgroundColor.cgColor
        containerView.layer?.cornerRadius = 8
    }
    
    private func createFeedbackLabel(
        text: String,
        containerWidth: CGFloat,
        containerHeight: CGFloat,
        backgroundColor: CGColor?
    ) -> NSTextField {
        let labelPadding: CGFloat = 10
        let textVerticalPadding: CGFloat = 10
        
        let feedbackLabel = NSTextField(labelWithString: text)
        feedbackLabel.font = NSFont.boldSystemFont(ofSize: 24)
        feedbackLabel.backgroundColor = .clear
        feedbackLabel.isBordered = false
        feedbackLabel.isEditable = false
        feedbackLabel.isSelectable = false
        feedbackLabel.alignment = .center
        
        if let bgColor = backgroundColor {
            let nsColor = NSColor(cgColor: bgColor) ?? .black
            feedbackLabel.textColor = nsColor.contrastingColor()
        } else {
            feedbackLabel.textColor = .white
        }
        
        let textSize = text.size(withAttributes: [.font: feedbackLabel.font!])
        feedbackLabel.frame = NSRect(
            x: labelPadding,
            y: containerHeight - textSize.height - textVerticalPadding,
            width: containerWidth - (labelPadding * 2),
            height: textSize.height
        )
        
        return feedbackLabel
    }
    
    private func createLinePreview(
        lineColor: NSColor,
        lineWidth: CGFloat,
        containerWidth: CGFloat
    ) -> LinePreviewView {
        let labelPadding: CGFloat = 10
        let textVerticalPadding: CGFloat = 10
        
        let lineView = LinePreviewView(frame: NSRect(
            x: labelPadding,
            y: textVerticalPadding,
            width: containerWidth - (labelPadding * 2),
            height: max(lineWidth, 10)
        ))
        lineView.lineColor = lineColor
        lineView.lineWidth = lineWidth
        
        return lineView
    }
    
    private func scheduleFeedbackRemoval(
        containerView: NSView,
        duration: TimeInterval,
        fadeOutDuration: TimeInterval
    ) {
        let totalDuration = duration + fadeOutDuration
        let removalTask = DispatchWorkItem { [weak self, weak containerView] in
            guard let view = containerView else { return }
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = fadeOutDuration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                view.animator().alphaValue = 0
            }, completionHandler: {
                view.removeFromSuperview()
                if self?.currentFeedbackView == view {
                    self?.currentFeedbackView = nil
                }
            })
        }
        
        feedbackRemovalTask = removalTask
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: removalTask)
        
        // Schedule removal in case animation doesn't complete
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.5) { [weak self, weak containerView] in
            guard let view = containerView else { return }
            if view.superview != nil {
                view.removeFromSuperview()
                if self?.currentFeedbackView == view {
                    self?.currentFeedbackView = nil
                }
            }
        }
    }
}

// Helper view to draw a line preview in the feedback overlay
class LinePreviewView: NSView {
    var lineColor: NSColor = .white
    var lineWidth: CGFloat = 3.0
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let path = NSBezierPath()
        let startPoint = NSPoint(x: 0, y: bounds.midY)
        let endPoint = NSPoint(x: bounds.width, y: bounds.midY)
        
        path.move(to: startPoint)
        path.line(to: endPoint)
        
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.stroke()
    }
}
