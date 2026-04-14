import Cocoa

class SelectionView: NSView {
    var config: Config!
    var startPoint: NSPoint?
    var currentPoint: NSPoint?
    var isDraggingSelection = false
    var dragOffset: NSPoint = .zero
    var activeHandle: ResizeHandle = .none
    var mousePosition: NSPoint?
    let handleSize: CGFloat = 8.0

    func currentRect() -> NSRect? {
        guard let start = startPoint,
            let current = currentPoint
        else { return nil }

        return NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(start.x - current.x),
            height: abs(start.y - current.y)
        )
    }

    func emitResult(start: NSPoint, end: NSPoint) {
        guard let window = self.window,
            let screen = window.screen
        else { return }

        let rectInView = NSRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(start.x - end.x),
            height: abs(start.y - end.y)
        )

        let scale = screen.backingScaleFactor
        let rectInWindow = self.convert(rectInView, to: nil)
        let rectInScreenPoints = window.convertToScreen(rectInWindow)
        let screenFrame = screen.frame

        // debugLogToFile("rectInScreenPoints: \(rectInScreenPoints) mode=\(config.mode)")

        switch config.mode {
        case .point:
            let x_pt = rectInScreenPoints.origin.x
            let y_pt = rectInScreenPoints.origin.y
            let w_pt = rectInScreenPoints.size.width
            let h_pt = rectInScreenPoints.size.height

            let x_sc = x_pt
            let y_sc = screenFrame.height - y_pt - h_pt
            let w_sc = w_pt
            let h_sc = h_pt

            let rect = Rect(x: x_sc, y: y_sc, w: w_sc, h: h_sc)
            print(rectToString(rect, format: config.format))
        case .pixel:
            let x_pt = rectInView.origin.x
            let y_pt = rectInView.origin.y
            let w_pt = rectInView.size.width
            let h_pt = rectInView.size.height

            let x_px = x_pt * scale
            let w_px = w_pt * scale
            let h_px = h_pt * scale
            let y_px = (screenFrame.height - y_pt - h_pt) * scale

            let rect = Rect(x: x_px, y: y_px, w: w_px, h: h_px)
            print(rectToString(rect, format: config.format))
        }

        fflush(stdout)
        NSApp.terminate(nil)
    }

    func updateCursor(at point: NSPoint) {
        if isDraggingSelection {
            NSCursor.openHand.set()
            return
        }

        // If resizing via a handle
        if let rect = currentRect() {
            let handle = detectHandle(at: point, in: rect, handleSize: handleSize)
            switch handle {
            case .topLeft, .bottomRight:
                NSCursor.closedHand.set()
                return
            case .topRight, .bottomLeft:
                NSCursor.closedHand.set()
                return
            case .none:
                break
            }
        }

        NSCursor.crosshair.set()
    }

    override func draw(_ dirtyRect: NSRect) {
        if config.dimBackground {
            NSColor.black.withAlphaComponent(0.3).setFill()
            dirtyRect.fill()
        }

        // If no active selection, draw full-screen crosshair at mousePosition.
        if let pos = mousePosition, startPoint == nil, currentPoint == nil, config.showCrosshair {
            let color = config.borderColor
            color.setStroke()

            let horiz = NSBezierPath()
            horiz.move(to: NSPoint(x: bounds.minX, y: pos.y))
            horiz.line(to: NSPoint(x: bounds.maxX, y: pos.y))
            horiz.lineWidth = config.lineWidth
            horiz.stroke()

            let vert = NSBezierPath()
            vert.move(to: NSPoint(x: pos.x, y: bounds.minY))
            vert.line(to: NSPoint(x: pos.x, y: bounds.maxY))
            vert.lineWidth = config.lineWidth
            vert.stroke()
        }

        guard let start = startPoint,
            let current = currentPoint
        else { return }

        let rect = NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(start.x - current.x),
            height: abs(start.y - current.y)
        )

        let handleRectSize: CGFloat = config.lineWidth + 4
        for corner in [
            NSPoint(x: rect.minX, y: rect.minY),
            NSPoint(x: rect.minX, y: rect.maxY),
            NSPoint(x: rect.maxX, y: rect.minY),
            NSPoint(x: rect.maxX, y: rect.maxY),
        ] {
            let handleRect = NSRect(
                x: corner.x - handleRectSize / 2,
                y: corner.y - handleRectSize / 2,
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

        switch config.borderStyle {
        case .solid:
            break

        case .dashed:
            path.setLineDash([6, 4], count: 2, phase: 0)

        case .dotted:
            path.setLineDash([1, 4], count: 2, phase: 0)

        case .double:
            let outer = NSBezierPath(rect: rect)
            outer.lineWidth = config.lineWidth
            config.borderColor.setStroke()
            outer.stroke()

            let insetAmount = config.lineWidth * 2
            let innerRect = rect.insetBy(dx: insetAmount, dy: insetAmount)
            if innerRect.width > 0, innerRect.height > 0 {
                let inner = NSBezierPath(rect: innerRect)
                inner.lineWidth = config.lineWidth
                config.borderColor.setStroke()
                inner.stroke()
            }
        }

        config.borderColor.setStroke()
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        // double click to confirm
        if event.clickCount == 2 {
            if let start = startPoint,
                let end = currentPoint
            {
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
                updateCursor(at: point)
                return
            }

            // move
            if rect.contains(point) {
                isDraggingSelection = true
                dragOffset = NSPoint(
                    x: point.x - rect.origin.x,
                    y: point.y - rect.origin.y
                )
                updateCursor(at: point)
                return
            }
        }
        // otherwise start new selection
        activeHandle = .none
        isDraggingSelection = false
        startPoint = point
        currentPoint = point
        updateCursor(at: point)
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
        updateCursor(at: point)
    }

    override func mouseUp(with event: NSEvent) {
        activeHandle = .none
        isDraggingSelection = false

        let point = convert(event.locationInWindow, from: nil)
        updateCursor(at: point)

        guard let start = startPoint,
            let end = currentPoint
        else { return }

        if !config.confirm {
            emitResult(start: start, end: end)
        }
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
        let point = convert(event.locationInWindow, from: nil)
        updateCursor(at: point)
    }

    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        mousePosition = point
        needsDisplay = true
        updateCursor(at: point)
    }
}
