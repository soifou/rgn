# rct - Region Capture Tool (macOS)

A lightweight screen region selection tool for macOS written in Swift. It
outputs screen coordinates that can be used directly in shell scripts (e.g. for
screen recording with ffmpeg).

## Features

- Click and drag to select a screen region
- Outputs coordinates as: `X Y WIDTH HEIGHT`
- Retina-aware coordinate handling
- Crosshair cursor during selection
- Keyboard shortcuts to cancel `ESC`, `<C-c>` and `<C-[>`
- Designed for CLI + shell script integration
- No GUI dependencies beyond macOS AppKit

## Motivation

On Linux, tools like `slop` and `hacksaw` make it easy to interactively select a
screen region from the command line and pass those coordinates into scripts for
workflows such as screen capture or recording.

On macOS, similar functionality is fragmented:

- `screencapture` provides region selection, but only for screenshots
- screen recording tools do not expose a CLI-friendly region picker
- no simple equivalent exists for piping interactive region selection into shell scripts

This project was created to fill that gap: a minimal, script-friendly region
selector for macOS that  integrates cleanly with tools such as `ffmpeg` for screen
recording automation.

## Use case

This tool is meant to be used as a helper for shell workflows, for example:

screen recording with ffmpeg automation scripts screenshot tooling UI testing /
debugging

## Build

Compile using Swift:

```sh
swiftc rct.swift -o rct
```

## Usage

Run the tool:

```sh
./rct
```

Then:

- Click and drag to select a region
- Release mouse: coordinates are printed to stdout

Example output: `64 1299 830 174`

## Example: screen recording with ffmpeg

```sh
coords=$(./rct)
set -- $coords

X=$1
Y=$2
W=$3
H=$4

ffmpeg \
    -f avfoundation \
    -framerate 30 \
    -i "1:none" \
    -vf "crop=${W}:${H}:${X}:${Y}" \
    -pix_fmt yuv420p \
    out.mp4
```

## Requirements

- macOS (tested on modern versions, i.e. Tahoe)
- Swift toolchain (swiftc)
- AppKit framework (included with macOS)

## Design notes

- Uses a full-screen transparent NSWindow overlay
- Captures mouse events via NSView
- Converts coordinates to pixel space using backingScaleFactor
- Designed for scripting interoperability rather than UI usage

## Future ideas

- Live width/height HUD
- Multi-monitor selection improvements
- Optional sound feedback toggle
- JSON output mode
- Snapshot preview before exit
