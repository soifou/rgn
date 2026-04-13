import Cocoa

func parseConfig(from arguments: [String]) -> Config {
    var config = Config()
    var i = 0

    while i < arguments.count {
        switch arguments[i] {

        case "--color":
            if i + 1 < arguments.count {
                config.borderColor = colorFromHex(arguments[i + 1])
                i += 1
            }

        case "--thickness":
            if i + 1 < arguments.count,
                let t = Double(arguments[i + 1])
            {
                config.lineWidth = CGFloat(t)
                i += 1
            }

        case "--fill":
            config.fillEnabled = true

        case "--alpha":
            if i + 1 < arguments.count,
                let a = Double(arguments[i + 1])
            {
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

        case "--format":
            if i + 1 < arguments.count {
                let value = arguments[i + 1]
                switch value {
                case "json":
                    config.format = .json
                default:
                    config.format = .text
                }
                i += 1
            }

        case "--mode":
            if i + 1 < arguments.count {
                let value = arguments[i + 1]
                switch value {
                case "pixel":
                    config.mode = .pixel
                case "point":
                    config.mode = .point
                default:
                    fputs("Unknown mode: \(value)\n", stderr)
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
