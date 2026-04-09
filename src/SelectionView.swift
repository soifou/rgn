import Cocoa

class SelectionView: NSView {
    var config: Config!
    var startPoint: NSPoint?
    var currentPoint: NSPoint?
    var isDraggingSelection = false
    var dragOffset: NSPoint = .zero
    var activeHandle: ResizeHandle = .none
    let handleSize: CGFloat = 8.0

    func currentRect() -> NSRect? {
        guard let start = startPoint,
              let current = currentPoint else { return nil }

        return NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(start.x - current.x),
            height: abs(start.y - current.y)
        )
    }

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

        let handleRectSize: CGFloat = 6
        for corner in [
            NSPoint(x: rect.minX, y: rect.minY),
            NSPoint(x: rect.minX, y: rect.maxY),
            NSPoint(x: rect.maxX, y: rect.minY),
            NSPoint(x: rect.maxX, y: rect.maxY)
        ] {
            let handleRect = NSRect(
                x: corner.x - handleRectSize/2,
                y: corner.y - handleRectSize/2,
                width: handleRectSize,
                height: handleRectSize
            )

            config.borderColor.setFill()
            NSBezierPath(rect: handleRect).fill()
        }

        if config.fillEnabled {
            config.borderColor
                .withAlphaComponent(config.fillAlpha)
                .setFill()
            NSBezierPath(rect: rect).fill()
        }

        let path = NSBezierPath(rect: rect)
        path.lineWidth = config.lineWidth

        if config.dashedBorder {
            path.setLineDash([6, 4], count: 2, phase: 0)
        }

        config.borderColor.setStroke()
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        // double click to confirm
        if event.clickCount == 2 {
            if let start = startPoint,
               let end = currentPoint {
                   emitResult(start: start, end: end)
            }
            return
        }

        // check if inside existing rect
        if let rect = currentRect() {
            // resize
            let handle = detectHandle(at: point, in: rect, handleSize: handleSize)
            if handle != .none {
                activeHandle = handle
                return
            }

            // move
            if rect.contains(point) {
                isDraggingSelection = true
                dragOffset = NSPoint(
                    x: point.x - rect.origin.x,
                    y: point.y - rect.origin.y
                )
                return
            }
        }
        // otherwise start new selection
        activeHandle = .none
        isDraggingSelection = false
        startPoint = point
        currentPoint = point
    }

    override func mouseDragged(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        if activeHandle != .none, let rect = currentRect() {
            var newRect = rect

            switch activeHandle {
            case .topLeft:
                newRect.origin.x = point.x
                newRect.size.width = rect.maxX - point.x
                newRect.size.height = point.y - rect.minY

            case .topRight:
                newRect.size.width = point.x - rect.minX
                newRect.size.height = point.y - rect.minY

            case .bottomLeft:
                newRect.origin.x = point.x
                newRect.origin.y = point.y
                newRect.size.width = rect.maxX - point.x
                newRect.size.height = rect.maxY - point.y

            case .bottomRight:
                newRect.origin.y = point.y
                newRect.size.width = point.x - rect.minX
                newRect.size.height = rect.maxY - point.y

            case .none:
                break
            }

            startPoint = newRect.origin
            currentPoint = NSPoint(
                x: newRect.maxX,
                y: newRect.maxY
            )
        } else if isDraggingSelection, let rect = currentRect() {

            let newOrigin = NSPoint(
                x: point.x - dragOffset.x,
                y: point.y - dragOffset.y
            )

            startPoint = newOrigin
            currentPoint = NSPoint(
                x: newOrigin.x + rect.width,
                y: newOrigin.y + rect.height
            )

        } else {
            currentPoint = point
        }

        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        activeHandle = .none
        isDraggingSelection = false

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
        guard let rect = currentRect() else { return }

        let point = convert(event.locationInWindow, from: nil)
        let handle = detectHandle(at: point, in: rect, handleSize: handleSize)

        switch handle {
        case .topLeft, .bottomRight:
            NSCursor.crosshair.set() // or diagonal resize
        case .topRight, .bottomLeft:
            NSCursor.crosshair.set()
        case .none:
            if config.showCrosshair {
                NSCursor.crosshair.set()
            }
        }
    }
}
