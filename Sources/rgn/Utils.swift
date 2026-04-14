import Cocoa

func printHelp() {
    print(
        """
        rgn — ReGioN capture tool for macOS

        USAGE:
          rgn [options]

        OPTIONS:
          --color <hex>         Set border color in hex format
          --style <style>       Set border style: solid (default), dashed, dotted, double
          --thickness <px>      Set border thickness in pixels
          --border-dash         Use dashed style for the border
          --fill                Fill selection area with transparent color
          --alpha <float>       Set transparency level for the overlay
          --no-dim              Disable dark background overlay
          --no-crosshair        Hide crosshair
          --no-confirm          Print to stdout on mouse release instead of double-click
          --format <format>     Output format: text (default), json
          --mode <name>         Coordinate mode: pixel (default), point

          -V, --version         Display version information and exit
          -h, --help            Show this help

        OUTPUT:
          Prints: X Y WIDTH HEIGHT (in pixels or points, see --mode)

        EXAMPLES:
          rgn
          rgn --color "#ff0000" --thickness 4
          rgn --fill --no-dim
        """)
}

func colorFromHex(_ hex: String) -> NSColor? {
    var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)

    if hex.hasPrefix("#") {
        hex = String(hex.dropFirst())
    }

    guard hex.count == 6,
        let value = Int(hex, radix: 16)
    else {
        return nil
    }

    let r = CGFloat((value >> 16) & 0xFF) / 255.0
    let g = CGFloat((value >> 8) & 0xFF) / 255.0
    let b = CGFloat(value & 0xFF) / 255.0

    return NSColor(calibratedRed: r, green: g, blue: b, alpha: 1.0)
}

func detectHandle(at point: NSPoint, in rect: NSRect, handleSize: CGFloat) -> ResizeHandle {
    let tl = NSPoint(x: rect.minX, y: rect.maxY)
    let tr = NSPoint(x: rect.maxX, y: rect.maxY)
    let bl = NSPoint(x: rect.minX, y: rect.minY)
    let br = NSPoint(x: rect.maxX, y: rect.minY)

    func near(_ a: NSPoint, _ b: NSPoint) -> Bool {
        abs(a.x - b.x) < handleSize && abs(a.y - b.y) < handleSize
    }

    if near(point, tl) { return .topLeft }
    if near(point, tr) { return .topRight }
    if near(point, bl) { return .bottomLeft }
    if near(point, br) { return .bottomRight }

    return .none
}

func rectToString(_ rect: Rect, format: OutputFormat) -> String {
    let x = Int(rect.x.rounded())
    let y = Int(rect.y.rounded())
    let w = Int(rect.w.rounded())
    let h = Int(rect.h.rounded())

    switch format {
    case .json:
        return "{\"x\":\(x),\"y\":\(y),\"width\":\(w),\"height\":\(h)}"
    case .text:
        return "\(x) \(y) \(w) \(h)"
    }
}
