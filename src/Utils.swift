import Cocoa

func printHelp() {
    print("""
rct — Region Capture Tool (macOS)

USAGE:
  rct [options]

OPTIONS:
  --color <hex>         Set border color in hex format
  --thickness <px>      Set border thickness in pixels
  --border-dash         Use dashed style for the border
  --fill                Fill selection area with transparent color
  --alpha <float>       Set transparency level for the overlay
  --no-dim              Disable dark background overlay
  --no-crosshair        Hide crosshair cursor
  --no-confirm          Print to stdout on mouse release instead of double-click
  --output <format>     Change stdout to another format (only json supported)

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
