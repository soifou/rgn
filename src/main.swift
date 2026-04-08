import Cocoa

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
            config.borderColor = colorFromHex(args[i + 1])
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

    case "--no-confirm":
        config.confirm = false

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
