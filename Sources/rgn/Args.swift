import Cocoa

func parseConfig(from arguments: [String]) -> Config {
    var config = Config()
    var i = 0

    while i < arguments.count {
        switch arguments[i] {

        case "--color":
            guard i + 1 < arguments.count,
                let color = colorFromHex(arguments[i + 1])
            else {
                fputs("Invalid color format. Use RRGGBB or \"#RRGGBB\".\n", stderr)
                exit(1)
            }
            config.borderColor = color
            i += 1

        case "--style":
            if i + 1 < arguments.count {
                switch arguments[i + 1] {
                case "solid": config.borderStyle = .solid
                case "dashed": config.borderStyle = .dashed
                case "dotted": config.borderStyle = .dotted
                case "double": config.borderStyle = .double
                default:
                    fputs("Unknown style: \(arguments[i + 1])\n", stderr)
                    fputs("Supported styles: solid, dashed, dotted, double\n", stderr)
                    exit(1)
                }
                i += 1
            }

        case "--thickness":
            guard i + 1 < arguments.count,
                let thickness = Double(arguments[i + 1])
            else {
                fputs("--thickness requires a number\n", stderr)
                exit(1)
            }
            config.lineWidth = CGFloat(thickness)
            i += 1

        case "--alpha":
            guard i + 1 < arguments.count,
                let alpha = Double(arguments[i + 1])
            else {
                fputs("--alpha requires a number\n", stderr)
                exit(1)
            }
            config.fillAlpha = CGFloat(max(0, min(1, alpha)))
            i += 1

        case "--fill":
            config.fillEnabled = true

        case "--no-dim":
            config.dimBackground = false

        case "--no-crosshair":
            config.showCrosshair = false

        case "--no-confirm":
            config.confirm = false

        case "--format":
            if i + 1 < arguments.count {
                let format = arguments[i + 1]
                switch format {
                case "json":
                    config.format = .json
                case "text":
                    config.format = .text
                default:
                    fputs("Unknown format: \(format)\n", stderr)
                    fputs("Supported format: text, json\n", stderr)
                    exit(1)
                }
                i += 1
            }

        case "--mode":
            if i + 1 < arguments.count {
                let mode = arguments[i + 1]
                switch mode {
                case "pixel":
                    config.mode = .pixel
                case "point":
                    config.mode = .point
                default:
                    fputs("Unknown mode: \(mode)\n", stderr)
                    fputs("Supported modes: pixel, point\n", stderr)
                    exit(1)
                }
                i += 1
            }

        case "-V", "--version":
            print("\(appName) \(appVersion)")
            exit(0)

        case "-h", "--help":
            printHelp()
            exit(0)

        default:
            break
        }
        i += 1
    }

    return config
}
