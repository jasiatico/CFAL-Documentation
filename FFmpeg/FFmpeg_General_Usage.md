# FFmpeg General Scripts

This repository contains two Python scripts for video processing using FFmpeg:

1. `generate_video_ffmpeg.py` - Converts a PNG image sequence into an MP4.
2. `mp4_to_gif_converter.py` - Converts an MP4 into an optimized GIF.

I also have created a bash script to automatically execute both python scripts:

1. `animate.sh` - executes both python scripts sequentially to generate an MP4 and GIF.

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

**Note: that lossless quality (100) creates very large filesizes. For optimum filesize per quality choose ~50**

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

### Dithering and Quality Details

**`--dither` Options:**

- `none`: Disables dithering (`paletteuse=dither=none`). May produce noticeable banding in gradients.
- `basic`: Uses ordered Bayer dithering with reduced strength (`paletteuse=dither=bayer:bayer_scale=5`). A balance of speed and appearance; this is the default.
- `best`: Uses Floyd–Steinberg dithering (`paletteuse=dither=floyd_steinberg`). Produces higher-quality visuals at the cost of processing time and larger output sizes.

**`--quality` Options:**

- `fast`: Uses `palettegen=stats_mode=diff`. Prioritizes speed and lighter file size; may skip subtle color details.
- `default`: Uses `palettegen` with no explicit mode. General-purpose balance between quality and speed.
- `best`: Uses `palettegen=stats_mode=full`. Analyzes entire frame sequence for maximum color preservation. Slower but produces richer color output.

Use `--quality` to control how colors are selected for the GIF palette, and `--dither` to control how those colors are blended spatially. For best visual fidelity, use `--quality best --dither best`. For speed, use `--quality fast --dither none`.

### Notes
- Only two of `--start`, `--end`, `--duration` can be used.
- GIFs are large by nature; use `gifsicle` to post-optimize if needed.

### Example
```bash
python mp4_to_gif_converter.py input.mp4 output.gif --fps 10 --width 800 --dither best --quality best --loop yes
```

---

## 3. `animate.sh`

**Purpose:** Automate the full pipeline by sequentially running `generate_video_ffmpeg.py` and `mp4_to_gif_converter.py`. This script reduces the need to manually invoke each Python script.

### Workflow
1. **Input & Output Directories** - Takes the input folder of PNG frames and an output folder.
2. **Generate MP4** - Calls `generate_video_ffmpeg.py` to produce MP4 file.
3. **Locate MP4** - Finds the most recently created MP4 in the output directory.
4. **Convert to GIF** - Passes the MP4 to `mp4_to_gif_converter.py` to generate an optimized GIF.

### Usage
```bash
./animate.sh [input_folder] [output_folder]
```

### Example
```bash
./animate /home/user/frames ./output
```
This will:
- Read PNG frames from `./frames`
- Output the MP4 and GIF to `./output`

### Notes
- Requires `generate_video_ffmpeg.py` and `mp4_to_gif_converter.py` to be located in `~/scripts/` or modify the bash file accordingly.
- The GIF and MP4 are generated with default parameters. Modify the script to pass extra arguments as needed.

```

---
**Author**  
Jackson Asiatico  
Embry-Riddle Aeronautical University  
[LinkedIn](https://www.linkedin.com/in/jacksonasiatico)