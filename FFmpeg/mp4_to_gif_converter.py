"""
mp4_to_gif_converter.py

Description:
    Convert MP4 video to optimized GIF with scaling, dithering, time trimming, and quality control.

Usage:
    python mp4_to_gif_converter.py input.mp4 output.gif [options]

Arguments:
    input.mp4             Input video file (MP4 format).
    output.gif            Output GIF file.

Options:
    --fps INT             Output GIF frame rate (default: 10).
    --width INT           Output width in pixels (preserves aspect ratio).
    --dither {none,basic,best}
                          Dithering method (default: best).
    --quality {fast,default,best}
                          Palette quality mode (default: default).
    --start TIME          Start time in seconds or HH:MM:SS format.
    --end TIME            End time in seconds or HH:MM:SS format.
    --duration TIME       Duration from start in seconds.
    --transparency        Enable RGBA input (preserve alpha).
    --loop {yes,no}       Loop GIF playback (default: yes).

Note:
    Only two of --start, --end, --duration may be specified.

Example:
    python3 mp4_to_gif_converter.py input.mp4 output.gif --fps 15 --width 800 --start 2 --duration 5 --dither best --quality best --transparency --loop yes

Author:
    Jackson Asiatico - Embry-Riddle Aeronautical University - https://www.linkedin.com/in/jacksonasiatico
"""

import argparse
import subprocess
import sys

def parse_args():
    parser = argparse.ArgumentParser(description="Convert MP4 to optimized GIF")

    parser.add_argument("input", help="Input MP4 file")
    parser.add_argument("output", nargs="?", help="Output GIF file (optional, defaults to input name with .gif)")


    parser.add_argument("--fps", type=int, default=10)
    parser.add_argument("--width", type=int, default=480)
    parser.add_argument("--dither", choices=["none", "basic", "best"], default="best")
    parser.add_argument("--quality", choices=["fast", "default", "best"], default="best")

    parser.add_argument("--start", type=str)
    parser.add_argument("--end", type=str)
    parser.add_argument("--duration", type=str)

    parser.add_argument("--transparency", action="store_true")
    parser.add_argument("--loop", choices=["yes", "no"], default="yes")

    return parser.parse_args()

def build_filter_chain(args):
    scale_filter = f"scale={args.width}:-1:flags=lanczos" if args.width else "scale=iw:ih:flags=lanczos"
    fps_filter = f"fps={args.fps}"
    fmt_filter = "format=rgba" if args.transparency else "format=rgb24"

    if args.dither == "none":
        dither = "dither=none"
    elif args.dither == "basic":
        dither = "dither=bayer:bayer_scale=5"
    else:
        dither = "dither=floyd_steinberg"

    return [
        "-filter_complex",
        f"[0:v]{fps_filter},{scale_filter},{fmt_filter}[x];[x][1:v]paletteuse={dither}"
    ]

def build_palettegen_filter(args):
    scale_filter = f"scale={args.width}:-1:flags=lanczos" if args.width else "scale=iw:ih:flags=lanczos"
    fps_filter = f"fps={args.fps}"
    fmt_filter = "format=rgba" if args.transparency else "format=rgb24"

    if args.quality == "fast":
        palettegen = "palettegen=stats_mode=diff"
    elif args.quality == "best":
        palettegen = "palettegen=stats_mode=full"
    else:
        palettegen = "palettegen"

    return [fps_filter, scale_filter, fmt_filter, palettegen]


def validate_time_logic(args):
    keys = [args.start, args.end, args.duration]
    count = sum(1 for k in keys if k)
    if count > 2:
        print("Error: Specify only two of --start, --end, --duration.")
        sys.exit(1)

def main():
    args = parse_args()
    if not args.output:
        args.output = args.input.rsplit('.', 1)[0] + ".gif"
    
    validate_time_logic(args)

    palette_path = "palette.png"

    input_opts = []
    if args.start:
        input_opts += ["-ss", args.start]
    if args.end:
        input_opts += ["-to", args.end]
    if args.duration:
        input_opts += ["-t", args.duration]

    # Generate palette
    subprocess.run([
        "ffmpeg", "-y", *input_opts, "-i", args.input,
        "-vf", ",".join(build_palettegen_filter(args)),
        palette_path
    ], check=True)

    # Generate GIF
    loop_val = "0" if args.loop == "yes" else "1"
    subprocess.run([
        "ffmpeg", "-y", *input_opts, "-i", args.input, "-i", palette_path,
        *build_filter_chain(args),
        "-loop", loop_val, args.output
    ], check=True)

if __name__ == "__main__":
    main()
