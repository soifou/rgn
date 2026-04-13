import Cocoa

struct Config {
    var confirm: Bool = true
    var borderColor: NSColor = .systemBlue
    var borderStyle: BorderStyle = .solid
    var lineWidth: CGFloat = 2.0
    var fillEnabled: Bool = false
    var fillAlpha: CGFloat = 0.2
    var dimBackground: Bool = true
    var showCrosshair: Bool = true
    var format: OutputFormat = .text
    var mode: OutputMode = .pixel
}
