import Cocoa

let appName = "rgn"
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
    .fullScreenAuxiliary,
]

let view = SelectionView(frame: screenFrame)
view.config = parseConfig(from: CommandLine.arguments)
window.contentView = view
window.makeKeyAndOrderFront(nil)

app.activate(ignoringOtherApps: true)
window.makeKey()
window.makeMain()
window.makeFirstResponder(view)

app.run()
