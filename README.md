# rgn

<p align="center">
  <img alt="logo" src="./assets/logo.png" />
</p>

Minimal screen region selector for macOS, designed for shell scripting
workflows. It lets you interactively select a region and outputs coordinates
directly usable in tools like ffmpeg.

<https://github.com/user-attachments/assets/2562dea2-3530-4aa5-97b7-4798d041be22>

## Features

- Click-and-drag region selection (move and resize to adjust)
- Outputs region coordinates in different format: X Y WIDTH HEIGHT
- Pixel-perfect (Retina-aware)
- Keyboard to cancel `ESC`, `<C-c>` and `<C-[>`
- Customizable appearance: `--color`, `--thickness`, `--fill`, `--no-dim`, etc
- No dependencies beyond macOS AppKit

## Installation

Using [mise](https://mise.jdx.dev/):

```sh
mise install github:soifou/rgn
```

Or download a prebuilt binary from the
[Releases](https://github.com/soifou/rgn/releases) page:

```sh
rgn-<version>-darwin_arm64.tar.gz (Apple Silicon)
rgn-<version>-darwin_amd64.tar.gz (Intel)
tar -xzf rgn-*.tar.gz
chmod +x rgn
./rgn
```

## Usage

```sh
rgn
```

1. Click and drag to select a region
2. (Optional) Drag inside the region to move, drag the corners to resize
3. Double click: coordinates are printed to stdout

> [!NOTE]
> Use `--no-confirm` to prints coordinates on release instead.

The coordinates are in the form: `X Y WIDTH HEIGHT`. You can either print
coordinates as pixels or points, controlled by `--mode`:

- `--mode pixel` (default): Values in pixels (Retina-aware). Relative to the
  selected screen’s bottom-left. Good for `ffmpeg`’s crop filter.
- `--mode point`: Values in points. In global CoreGraphics space, origin at
  top-left of the main display. Good for `screencapture -R`.

## Options

| Option              | Description                                               |
| ------------------- | --------------------------------------------------------- |
| `--color <hex>`     | Set border color in hex format                            |
| `--style <style>`   | Set border style: solid (default), dashed, dotted, double |
| `--thickness <px>`  | Set border thickness in pixels                            |
| `--fill`            | Fill selection area with transparent color                |
| `--alpha <float>`   | Set transparency level for the overlay                    |
| `--no-dim`          | Disable dark background overlay                           |
| `--no-crosshair`    | Hide crosshair                                            |
| `--no-confirm`      | Print to stdout on mouse release instead of double-click  |
| `--format <format>` | Output format: text (default), json                       |
| `--mode <mode>`     | Coordinate mode: pixel (default), point                   |
| `-V`, `--version`   | Display version information and exit                      |
| `-h`, `--help`      | Show help                                                 |

## Examples

### Screen recording with ffmpeg

```sh
coords=$(rgn --mode pixel)
set -- $coords
X=$1 Y=$2 W=$3 H=$4

ffmpeg \
    -f avfoundation \
    -framerate 30 \
    -i "1:none" \
    -vf "crop=${W}:${H}:${X}:${Y}" \
    -pix_fmt yuv420p \
    out.mp4
```

### Screenshot with screencapture

```sh
coords=$(rgn --mode point)
set -- $coords
X=$1 Y=$2 W=$3 H=$4

screencapture -x -R"$X,$Y,$W,$H" out.png
```

## Motivation

On Linux, tools like [slop](https://github.com/naelstrof/slop) or
[hacksaw](https://github.com/neXromancers/hacksaw) provide simple ways to select
a screen region and pipe coordinates into scripts.

On macOS, this workflow seem to be missing:

- `screencapture` supports region selection, but only for screenshots
- no CLI tool exists to select a region and reuse it for video recording
- GUI tools don't integrate well with shell pipelines

`rgn` fills that gap: a small, script-friendly region picker for macOS.

## Build

Requirements:

- macOS (tested on modern versions, i.e. Tahoe)
- Swift toolchain (swiftc)
- AppKit framework (included with macOS)

```sh
make
```

## Contributing

Issues and ideas are welcome.

Feel free to open a PR or discussion if you have improvements or feature
requests.

## License

MIT
