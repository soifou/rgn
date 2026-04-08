import Cocoa

class SelectionView: NSView {
    var config: Config!
    var startPoint: NSPoint?
    var currentPoint: NSPoint?

    func emitResult(start: NSPoint, end: NSPoint) {
        guard let window = self.window,
              let screen = window.screen else { return }

        let scale = screen.backingScaleFactor
        let screenFrame = screen.frame

        let x_pt = min(start.x, end.x)
        let y_pt = min(start.y, end.y)
        let w_pt = abs(start.x - end.x)
        let h_pt = abs(start.y - end.y)

        let x_px = Int(x_pt * scale)
        let w_px = Int(w_pt * scale)
        let h_px = Int(h_pt * scale)
        let y_px = Int((screenFrame.height - y_pt - h_pt) * scale)

        if config.outputJSON {
            print("{\"x\":\(x_px),\"y\":\(y_px),\"width\":\(w_px),\"height\":\(h_px)}")
        } else {
            print("\(x_px) \(y_px) \(w_px) \(h_px)")
        }

        fflush(stdout)
        NSApp.terminate(nil)
    }

    override func draw(_ dirtyRect: NSRect) {

        if config.dimBackground {
            NSColor.black.withAlphaComponent(0.3).setFill()
            dirtyRect.fill()
        }

        guard let start = startPoint,
              let current = currentPoint else { return }

        let rect = NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(start.x - current.x),
            height: abs(start.y - current.y)
        )

        if config.fillEnabled {
            config.strokeColor
                .withAlphaComponent(config.fillAlpha)
                .setFill()
            NSBezierPath(rect: rect).fill()
        }

        let path = NSBezierPath(rect: rect)
        path.lineWidth = config.lineWidth

        if config.dashedBorder {
            path.setLineDash([6, 4], count: 2, phase: 0)
        }

        config.strokeColor.setStroke()
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            if let start = startPoint,
               let end = currentPoint {
                   emitResult(start: start, end: end)
            }
            return
        }

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

        if !config.confirm {
            emitResult(start: start, end: end)
        }
    }

    // crosshair
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
        if config.showCrosshair {
            NSCursor.crosshair.set()
        }
    }

    override func mouseMoved(with event: NSEvent) {
        if config.showCrosshair {
            NSCursor.crosshair.set()
        }
    }
}
