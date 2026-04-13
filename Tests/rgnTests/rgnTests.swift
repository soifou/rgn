import Cocoa
import Testing

@testable import rgn

@Suite
struct RgnTests {
    @Test
    func colorFromHex_parsesValidHex() throws {
        let color = colorFromHex("#ff0000")
        let converted = color.usingColorSpace(.deviceRGB)!
        #expect(converted.redComponent > 0.9, "red should be high")
        #expect(converted.greenComponent < 0.2, "green should be low")
        #expect(converted.blueComponent < 0.2, "blue should be low")
    }

    @Test
    func colorFromHex_invalidFallsBack() throws {
        let color = colorFromHex("not-a-color")
        let converted = color.usingColorSpace(.deviceRGB)!
        #expect(converted.redComponent >= 0.0 && converted.redComponent <= 1.0)
    }

    @Test
    func rectToString_textFormatRoundsValues() throws {
        let rect = Rect(x: 10.4, y: 20.6, w: 30.4, h: 40.6)
        let s = rectToString(rect, format: .text)
        #expect(s == "10 21 30 41")
    }

    @Test
    func rectToString_jsonFormat() throws {
        let rect = Rect(x: 1, y: 2, w: 3, h: 4)
        let s = rectToString(rect, format: .json)
        #expect(s == #"{"x":1,"y":2,"width":3,"height":4}"#)
    }

    @Test
    func detectHandle_topLeft() throws {
        let rect = NSRect(x: 100, y: 100, width: 200, height: 200)
        let handleSize: CGFloat = 8
        let pointNearTopLeft = NSPoint(x: rect.minX + 2, y: rect.maxY - 2)
        let handle = detectHandle(at: pointNearTopLeft, in: rect, handleSize: handleSize)
        #expect(handle == .topLeft)
    }

    @Test
    func detectHandle_noneOutside() throws {
        let rect = NSRect(x: 100, y: 100, width: 200, height: 200)
        let handleSize: CGFloat = 8
        let pointFar = NSPoint(x: 10, y: 10)
        let handle = detectHandle(at: pointFar, in: rect, handleSize: handleSize)
        #expect(handle == .none)
    }

    @Test
    func parseConfig_setsColorAndThickness() throws {
        let args = [
            "rgn",
            "--color", "#00ff00",
            "--thickness", "5",
        ]
        let config = parseConfig(from: args)

        #expect(config.lineWidth == 5)

        let converted = config.borderColor.usingColorSpace(.deviceRGB)!
        #expect(converted.greenComponent > 0.8, "green should be high")
        #expect(converted.redComponent < 0.2, "red should be low")
        #expect(converted.blueComponent < 0.2, "blue should be low")
    }

    @Test
    func parseConfig_setsFormatAndMode() throws {
        let args = [
            "rgn",
            "--format", "json",
            "--mode", "point",
            "--no-confirm",
        ]
        let config = parseConfig(from: args)

        #expect(config.format == .json)
        #expect(config.mode == .point)
        #expect(config.confirm == false)
    }
}
