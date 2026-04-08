import Cocoa

class CaptureWindow: NSWindow {
    var onCancel: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func keyDown(with event: NSEvent) {
        let isCtrl = event.modifierFlags.contains(.control)

        if event.keyCode == 53 { // ESC
            cancel()
            return
        }

        if isCtrl, let chars = event.charactersIgnoringModifiers?.lowercased() {
            if chars == "c" || chars == "[" {
                cancel()
                return
            }
        }

        super.keyDown(with: event)
    }

    private func cancel() {
        NSSound.beep()
        onCancel?()
        NSApp.terminate(nil)
    }
}

class SelectionView: NSView {
    var startPoint: NSPoint?
    var currentPoint: NSPoint?

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.3).setFill()
        dirtyRect.fill()

        guard let start = startPoint,
              let current = currentPoint else { return }

        let rect = NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(start.x - current.x),
            height: abs(start.y - current.y)
        )

        NSColor.systemBlue.setStroke()
        NSBezierPath(rect: rect).stroke()
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let start = startPoint,
              let end = currentPoint,
              let window = self.window,
              let screen = window.screen else { return }

        let scale = screen.backingScaleFactor
        let screenFrame = screen.frame

        let x_pt = min(start.x, end.x)
        let y_pt = min(start.y, end.y)
        let w_pt = abs(start.x - end.x)
        let h_pt = abs(start.y - end.y)

        // pixel conversion
        let x_px = Int(x_pt * scale)
        let w_px = Int(w_pt * scale)
        let h_px = Int(h_pt * scale)

        // correct Y flip
        let y_px = Int((screenFrame.height - y_pt - h_pt) * scale)

        print("\(x_px) \(y_px) \(w_px) \(h_px)")
        fflush(stdout)

        NSApp.terminate(nil)
    }

    // crosshair stuff
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        NSCursor.crosshair.set()
    }
    override func mouseMoved(with event: NSEvent) {
        NSCursor.crosshair.set()
    }
    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        for area in trackingAreas {
            removeTrackingArea(area)
        }

        let tracking = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseMoved, .cursorUpdate, .inVisibleRect],
            owner: self,
            userInfo: nil
        )

        addTrackingArea(tracking)
    }
    override func cursorUpdate(with event: NSEvent) {
        NSCursor.crosshair.set()
    }
}

// Setup app
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let screenFrame = NSScreen.main!.frame

let window = CaptureWindow(
    contentRect: screenFrame,
    styleMask: .borderless,
    backing: .buffered,
    defer: false
)

window.level = .floating
window.isOpaque = false
window.backgroundColor = .clear
window.ignoresMouseEvents = false

window.collectionBehavior = [
    .canJoinAllSpaces,
    .fullScreenAuxiliary
]

let view = SelectionView(frame: screenFrame)
window.contentView = view

window.makeKeyAndOrderFront(nil)

app.activate(ignoringOtherApps: true)
window.makeKey()
window.makeMain()
window.makeFirstResponder(view)

app.run()
