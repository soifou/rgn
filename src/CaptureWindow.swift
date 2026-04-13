import Cocoa

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
        exit(1)
    }
}
