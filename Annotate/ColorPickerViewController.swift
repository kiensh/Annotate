import Cocoa
import SwiftUI

class ColorSwatchButton: NSButton {
    var swatchColor: NSColor = .clear {
        didSet { needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        swatchColor.setFill()
        NSBezierPath(rect: bounds).fill()
    }
}

class ColorPickerViewController: NSViewController {
    let colorPalette: [NSColor] = [
        .systemRed, .systemOrange, .systemYellow,
        .systemGreen, .cyan, .systemIndigo,
        .magenta, .white, .black,
    ]

    override func loadView() {
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 150, height: 100))

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = 0

        let columnsPerRow = 3
        for chunk in colorPalette.chunked(into: columnsPerRow) {
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.alignment = .centerY
            rowStack.distribution = .fillEqually
            rowStack.spacing = 5

            for color in chunk {
                let button = ColorSwatchButton(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
                button.swatchColor = color
                button.target = self
                button.action = #selector(colorSwatchClicked(_:))
                rowStack.addArrangedSubview(button)
            }
            stackView.addArrangedSubview(rowStack)
        }

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])

        self.view = containerView
    }

    @objc func colorSwatchClicked(_ sender: ColorSwatchButton) {
        guard let appDelegate = AppDelegate.shared else { return }
        let selectedColor = sender.swatchColor

        // Save color to UserDefaults
        if let colorData = try? NSKeyedArchiver.archivedData(
            withRootObject: selectedColor, requiringSecureCoding: false)
        {
            UserDefaults.standard.set(colorData, forKey: "SelectedColor")
        }

        // Apply color app-wide
        appDelegate.currentColor = selectedColor
        appDelegate.overlayWindows.values.forEach { $0.currentColor = selectedColor }
        appDelegate.updateStatusBarIcon(with: selectedColor)

        // Close the popover
        if let presentingPopover = self.view.window?.parent?.contentViewController as? NSPopover {
            presentingPopover.close()
        } else if let parentWindow = self.view.window {
            parentWindow.close()
        }
    }
}
