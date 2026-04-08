# rct - Region Capture Tool (macOS)

Minimal screen region selector for macOS, designed for shell scripting
workflows. It lets you interactively select a region and outputs coordinates
directly usable in tools like ffmpeg.

## Motivation

On Linux, tools like `slop` or `hacksaw` provide simple ways to select a screen
region and pipe coordinates into scripts.

On macOS, this workflow seem to be missing:

- `screencapture` supports region selection, but only for screenshots
- no CLI tool exists to select a region and reuse it for video recording
- GUI tools don't integrate well with shell pipelines

rct fills that gap: a small, script-friendly region picker for macOS.

## Features

- Click-and-drag region selection
- Outputs coordinates: X Y WIDTH HEIGHT
- Pixel-perfect (Retina-aware)
- Crosshair cursor
- Keyboard to cancel `ESC`, `<C-c>` and `<C-[>`
- Customizable appearance: `--color`, `--thickness`, `--fill`, `--no-dim`
- No dependencies beyond macOS AppKit

## Requirements

- macOS (tested on modern versions, i.e. Tahoe)
- Swift toolchain (swiftc)
- AppKit framework (included with macOS)

## Build

```sh
swiftc rct.swift -o rct
```

## Usage

```sh
./rct
```

1. Click and drag to select a region
2. Release mouse: coordinates are printed to stdout

Example: `64 1299 830 174`

## CLI arguments

For ricers among us, few arguments allows you to tweak the appearance of the
grab:

- Custom color: `./rct --color "#ffccdd"`
- Thick red border: `./rct --color ff0000 --thickness 4`
- With fill: `./rct --fill`
- No dark overlay: `./rct --no-dim`
- Combined: `./rct --color "#00ffcc" --thickness 3 --fill --no-dim`

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
