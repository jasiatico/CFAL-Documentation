"""
generate_video_ffmpeg.py

Description:
    This script converts a sequence of PNG images into an MP4 video using FFmpeg and x264 encoding.
    It automatically detects image sequences with a common prefix, validates input, and supports
    quality control, duration targeting, and FPS configuration.

Functionality:
    - Validates PNG sequence (single prefix only)
    - Automatically sorts frames by numerical index
    - Derives FPS from target duration or uses fixed FPS
    - Caps FPS at 60 for compatibility
    - Converts frames to MP4 using libx264 encoder
    - Supports adjustable quality (mapped from 1–100 scale to CRF 51–0)
    - Output filename includes encoded metadata tags (fps, duration, quality)

Usage:
    python generate_video.py <input_dir> <output_dir> [options]

Arguments:
    input_dir      Directory containing PNG image sequence
    output_dir     Directory to write the resulting MP4 file

Options:
    --fps INT            Frames per second (default: 20)
    --duration FLOAT     Target duration in seconds (overrides --fps if specified)
    --quality INT        Quality from 1 (worst) to 100 (lossless), mapped to CRF scale

Notes:
    - Requires FFmpeg compiled with libx264 support
    - Output filename is auto-tagged (e.g. _fps30_dur10p5_q80)
    - All image files must follow the same prefix pattern and have numeric suffixes

Example:
    python generate_video_ffmpeg.py ./frames ./video_output --duration 8.5 --quality 80

Author:
    Jackson Asiatico - Embry-Riddle Aeronautical University - https://www.linkedin.com/in/jacksonasiatico
"""

import os
import subprocess
import glob
import sys
import re
import tempfile
import shutil
import argparse
from collections import defaultdict


def validate_input_images(input_dir):
    images = glob.glob(os.path.join(input_dir, "*.png"))
    if not images:
        print("Error: No PNG images found.")
        sys.exit(1)

    roots = defaultdict(list)
    for img in images:
        base = os.path.basename(img)
        match = re.match(r"(\D+)\d+\.png", base)
        if match:
            roots[match.group(1)].append(img)
        else:
            print(f"Warning: {base} doesn't match expected pattern.")

    if len(roots) > 1:
        print("Error: Multiple image root names found:")
        for root, files in roots.items():
            print(f"- {root}: {len(files)} files")
        sys.exit(1)

    root_name = next(iter(roots))
    sorted_images = sorted(roots[root_name], key=lambda x: int(re.search(r"(\d+)\.png", x).group(1)))
    return sorted_images, root_name


def build_suffix(fps, duration, fps_was_explicit, quality):
    suffix_parts = []
    if fps_was_explicit:
        suffix_parts.append(f"fps{int(round(fps))}")
    if duration is not None:
        dur_str = str(duration).replace('.', 'p')
        suffix_parts.append(f"dur{dur_str}")
    if quality is not None:
        suffix_parts.append(f"q{quality}")
    return "_" + "_".join(suffix_parts) if suffix_parts else ""


def map_quality_to_crf(quality):
    quality = max(0, min(100, quality))
    return round(51 - (quality / 100) * 51)


def generate_animation(input_dir, output_dir, fps=20, duration=None, default_fps=20, quality=None, fps_was_explicit=False):
    os.makedirs(output_dir, exist_ok=True)
    images, prefix = validate_input_images(input_dir)
    num_frames = len(images)

    if duration:
        derived_fps = round(num_frames / duration)
        fps = min(derived_fps, 60)
        fps_was_explicit = False

    crf = 18 if quality is None else map_quality_to_crf(quality)
    suffix = build_suffix(fps, duration, fps_was_explicit, quality)

    temp_seq_dir = tempfile.mkdtemp()
    try:
        for i, img in enumerate(images, 1):
            link_name = os.path.join(temp_seq_dir, f"img_{i:05d}.png")
            try:
                os.symlink(os.path.abspath(img), link_name)
            except Exception as e:
                print(f"Failed to create symlink for {img}: {e}")
                shutil.rmtree(temp_seq_dir)
                sys.exit(1)

        input_pattern = os.path.join(temp_seq_dir, "img_%05d.png")
        output_video = os.path.join(output_dir, f"{prefix}{suffix}.mp4")

        try:
            subprocess.run([
                "ffmpeg", "-y", "-framerate", str(fps), "-i", input_pattern,
                "-c:v", "libx264", "-preset", "veryfast", "-crf", str(crf), "-pix_fmt", "yuv420p",
                output_video
            ], check=True)
        except subprocess.CalledProcessError:
            print("Error generating MP4")

    finally:
        shutil.rmtree(temp_seq_dir, ignore_errors=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate MP4 animation from PNG sequence")
    parser.add_argument("input_dir", help="Directory containing PNG files")
    parser.add_argument("output_dir", help="Directory to save MP4")
    parser.add_argument("--fps", type=int, default=None, help="Frames per second")
    parser.add_argument("--duration", type=float, help="Target duration in seconds")
    parser.add_argument("--quality", type=int, help="Quality level from 1 (worst) to 100 (best/lossless)")

    args = parser.parse_args()
    fps = args.fps if args.fps is not None else 20
    fps_explicit = args.fps is not None

    generate_animation(
        args.input_dir,
        args.output_dir,
        fps=fps,
        duration=args.duration,
        default_fps=20,
        quality=args.quality,
        fps_was_explicit=fps_explicit
    )

