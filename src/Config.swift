import Cocoa

struct Config {
    var confirm: Bool = true
    var strokeColor: NSColor = .systemBlue
    var lineWidth: CGFloat = 2.0
    var fillEnabled: Bool = false
    var fillAlpha: CGFloat = 0.2
    var dimBackground: Bool = true
    var dashedBorder: Bool = false
    var showCrosshair: Bool = true
    var outputJSON: Bool = false
}
