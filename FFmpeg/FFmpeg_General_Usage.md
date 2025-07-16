# FFmpeg General Scripts

This repository contains two Python scripts for video processing using FFmpeg:

1. `generate_video_ffmpeg.py` - Converts a PNG image sequence into an MP4.
2. `mp4_to_gif_converter.py` - Converts an MP4 into an optimized GIF.

---

## 1. `generate_video_ffmpeg.py`

**Purpose:** Convert a sequence of PNG images into an MP4 video using x264 encoding.

### Features
- Validates image sequence with a single root prefix.
- Automatically sorts frames by numeric suffix.
- Derives FPS from duration or accepts fixed FPS.
- Caps FPS at 60 for compatibility.
- Converts frames to MP4 using `libx264`.
- Supports adjustable quality (1–100 mapped to CRF).
- Auto-generates filename metadata (e.g. `_fps30_dur10p5_q80`).

### Usage
```bash
python generate_video_ffmpeg.py <input_dir> <output_dir> [options]
```

### Arguments
- `input_dir`: Directory with PNG image frames.
- `output_dir`: Output directory for the MP4.

### Options
- `--fps INT`: Frame rate (default: 20).
- `--duration FLOAT`: Target duration in seconds (overrides FPS).
- `--quality INT`: Quality level (1 = worst, 100 = best/lossless).

### Notes
- Requires FFmpeg compiled with `libx264`.
- All input files must share the same prefix and numeric suffix.

### Example
```bash
python generate_video_ffmpeg.py ./frames ./output --duration 8.5 --quality 80
```

---

## 2. `mp4_to_gif_converter.py`

**Purpose:** Convert an MP4 video into an optimized animated GIF.

### Features
- Width downscaling (preserves aspect ratio).
- Start/end/duration trimming (pick any two).
- Supports RGBA input for transparency.
- Dithering control: `none`, `basic`, `best`.
- Quality control: `fast`, `default`, `best`.
- GIF loop control: `yes`, `no`.

### Usage
```bash
python mp4_to_gif_converter.py input.mp4 output.gif [options]
```

### Arguments
- `input.mp4`: MP4 input video file.
- `output.gif`: Output GIF path.

### Options
- `--fps INT`: Output FPS (default: 15).
- `--width INT`: Output width in pixels.
- `--dither`: Dithering method (`none`, `basic`, `best`).
- `--quality`: Palette mode (`fast`, `default`, `best`).
- `--start TIME`: Start time (in seconds or HH:MM:SS).
- `--end TIME`: End time.
- `--duration TIME`: Duration in seconds.
- `--transparency`: Enable alpha input.
- `--loop {yes,no}`: Loop GIF (default: yes).

### Notes
- Only two of `--start`, `--end`, `--duration` can be used.
- GIFs are large by nature; use `gifsicle` to post-optimize if needed.

### Example
```bash
python mp4_to_gif_converter.py input.mp4 output.gif --fps 10 --width 800 --dither best --quality best --loop yes
```

---

**Author**  
Jackson Asiatico  
Embry-Riddle Aeronautical University  
[LinkedIn](https://www.linkedin.com/in/jacksonasiatico)