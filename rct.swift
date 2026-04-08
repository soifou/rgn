import Cocoa

struct Config {
    var strokeColor: NSColor = .systemBlue
    var lineWidth: CGFloat = 2.0
    var fillEnabled: Bool = false
    var fillAlpha: CGFloat = 0.2
    var dimBackground: Bool = true
    var dashedBorder: Bool = false
    var showCrosshair: Bool = true
    var outputJSON: Bool = false
}

func printHelp() {
    print("""
rct — Region Capture Tool (macOS)

USAGE:
  rct [options]

OPTIONS:
  --color <hex>        Border color (e.g. "#ffccdd" or ffccdd, default: blue)
  --thickness <px>     Border thickness (default: 2)
  --fill               Fill selection with transparent color
  --no-dim             Disable background dimming

  -h, --help           Show this help

OUTPUT:
  Prints: X Y WIDTH HEIGHT (in pixels, ffmpeg-ready)

EXAMPLES:
  rct
  rct --color "#ff0000" --thickness 4
  rct --fill --no-dim
""")
}

func colorFromHex(_ hex: String) -> NSColor {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)

    if hex.hasPrefix("#") {
        hex.removeFirst()
    }

    guard hex.count == 6,
          let value = Int(hex, radix: 16) else {
        return NSColor.systemBlue // fallback
    }

    let r = CGFloat((value >> 16) & 0xFF) / 255.0
    let g = CGFloat((value >> 8) & 0xFF) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0

    return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
}

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
    var config: Config!
    var startPoint: NSPoint?
    var currentPoint: NSPoint?

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

        let x_px = Int(x_pt * scale)
        let w_px = Int(w_pt * scale)
        let h_px = Int(h_pt * scale)
        let y_px = Int((screenFrame.height - y_pt - h_pt) * scale)

        if config.outputJSON {
            print("""
            {"x":\(x_px),"y":\(y_px),"width":\(w_px),"height":\(h_px)}
            """)
        } else {
            print("\(x_px) \(y_px) \(w_px) \(h_px)")
        }
        fflush(stdout)

        NSApp.terminate(nil)
    }

    // crosshair (stable)
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

var config = Config()

let args = CommandLine.arguments
var i = 0
while i < args.count {
    switch args[i] {

    case "--color":
        if i + 1 < args.count {
            config.strokeColor = colorFromHex(args[i + 1])
            i += 1
        }

    case "--thickness":
        if i + 1 < args.count,
           let t = Double(args[i + 1]) {
            config.lineWidth = CGFloat(t)
            i += 1
        }

    case "--fill":
        config.fillEnabled = true

    case "--alpha":
        if i + 1 < args.count,
           let a = Double(args[i + 1]) {
            config.fillAlpha = CGFloat(max(0, min(1, a)))
            i += 1
        }

    case "--no-dim":
        config.dimBackground = false

    case "--border-dash":
        config.dashedBorder = true

    case "--no-crosshair":
        config.showCrosshair = false

    case "--output":
        if i + 1 < args.count, args[i + 1] == "json" {
            config.outputJSON = true
            i += 1
        }

    case "-h", "--help":
        printHelp()
        exit(0)

    default:
        break
    }
    i += 1
}

let view = SelectionView(frame: screenFrame)
view.config = config
window.contentView = view
window.makeKeyAndOrderFront(nil)

app.activate(ignoringOtherApps: true)
window.makeKey()
window.makeMain()
window.makeFirstResponder(view)

app.run()
