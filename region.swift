import Cocoa

class SelectionView: NSView {
    var startPoint: NSPoint?
    var currentPoint: NSPoint?

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.3).setFill()
        dirtyRect.fill()

        if let start = startPoint, let current = currentPoint {
            let rect = NSRect(
                x: min(start.x, current.x),
                y: min(start.y, current.y),
                width: abs(start.x - current.x),
                height: abs(start.y - current.y)
            )

            NSColor.clear.setFill()
            NSBezierPath(rect: rect).fill()

            NSColor.systemBlue.setStroke()
            let path = NSBezierPath(rect: rect)
            path.lineWidth = 2
            path.stroke()
        }
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
              let end = currentPoint else { return }

        let x = Int(min(start.x, end.x))
        let y = Int(min(start.y, end.y))
        let w = Int(abs(start.x - end.x))
        let h = Int(abs(start.y - end.y))

        print("\(x) \(y) \(w) \(h)")
        fflush(stdout)
        NSApp.terminate(nil)
    }
}

// Setup app
let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let screen = NSScreen.main!.frame

let window = NSWindow(
    contentRect: screen,
    styleMask: .borderless,
    backing: .buffered,
    defer: false
)

window.level = .screenSaver
window.isOpaque = false
window.backgroundColor = .clear
window.ignoresMouseEvents = false
window.makeKeyAndOrderFront(nil)
window.makeFirstResponder(nil)

// Crosshair cursor
NSCursor.crosshair.set()

let view = SelectionView(frame: screen)
window.contentView = view

app.activate(ignoringOtherApps: true)
app.run()
