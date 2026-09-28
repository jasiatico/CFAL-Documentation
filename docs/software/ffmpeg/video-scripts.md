# Image Sequences to Video

The lab keeps three small scripts for turning a folder of PNG frames into an MP4 video and a GIF. They wrap FFmpeg commands that are easy to get wrong by hand: frame ordering, quality settings, and GIF color palettes.

| Script | What it does |
|--------|--------------|
| [`generate_video_ffmpeg.py`](./scripts/generate_video_ffmpeg.py) | PNG frames to an H.264 MP4 |
| [`mp4_to_gif_converter.py`](./scripts/mp4_to_gif_converter.py) | MP4 to an optimized GIF |
| [`animate.sh`](./scripts/animate.sh) | Runs both in a row with default settings |

**Requirements:** Python 3 and an `ffmpeg` on your `PATH` that was built with `libx264`. On Vega, see [Building FFmpeg on Vega](./vega-compile.md).

---

## Quick start

Download all three scripts into the same folder, make the shell script executable, and run it on your frames:

```bash
chmod +x animate.sh
./animate.sh ./frames ./output
```

This writes an MP4 and a GIF into `./output`. For control over frame rate, quality, size or trimming, run the two Python scripts directly as described below.

---

## 1. `generate_video_ffmpeg.py`

Converts a folder of PNG frames into an MP4 using the H.264 (x264) encoder.

```bash
python3 generate_video_ffmpeg.py <input_dir> <output_dir> [options]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--fps INT` | 20 | Frames per second. |
| `--duration FLOAT` | not set | Target video length in seconds. The frame rate is set to *number of frames ÷ duration*, capped at 240. Ignored if you also pass `--fps`. |
| `--quality INT` | 50 | Quality from 1 (worst) to 100 (lossless). |

**How it works:**
- **Frame naming.** Frames must be named `<prefix><number>.png`, for example `frame_0001.png`, `frame_0002.png`. Every frame must share the same prefix, and the prefix can't contain digits. Frames are sorted by their number, so `frame_2.png` comes before `frame_10.png` even without zero padding.
- **Quality.** `--quality` is converted to x264's CRF setting (51 − quality × 0.51), so 50 becomes CRF 26 and 100 becomes CRF 0. Around 50 gives the best balance of quality and file size. 100 is lossless and produces very large files.
- **Output name.** The output file is named after the frame prefix plus the settings used. For example, frames named `frame_0001.png` with `--duration 8.5 --quality 80` produce `frame__dur8p5_q80.mp4`. The double underscore comes from the prefix ending in `_`. `fps` appears in the name only if you set `--fps` yourself.
- **Errors.** If FFmpeg fails, the script prints an error and exits with a non-zero status, so a job script or `animate.sh` can detect the failure.

**Example:**

```bash
python3 generate_video_ffmpeg.py ./frames ./output --duration 8.5 --quality 80
```

---

## 2. `mp4_to_gif_converter.py`

Converts an MP4 into an animated GIF. It uses FFmpeg's two-pass palette method, which gives much better colors than a direct conversion.

```bash
python3 mp4_to_gif_converter.py input.mp4 [output.gif] [options]
```

If you leave out `output.gif`, the GIF is written next to the input with the same name.

| Option | Default | Description |
|--------|---------|-------------|
| `--fps INT` | 10 | GIF frame rate. |
| `--width INT` | 480 | Output width in pixels; height follows the aspect ratio. Use `0` to keep the original size. |
| `--dither {none,basic,best}` | `best` | How colors are blended (see below). |
| `--quality {fast,default,best}` | `best` | How the color palette is chosen (see below). |
| `--start TIME` | not set | Start time, in seconds or `HH:MM:SS`. |
| `--end TIME` | not set | End time. |
| `--duration TIME` | not set | Length in seconds from the start. |
| `--transparency` | off | Keep the alpha channel from the input. |
| `--loop {yes,no}` | `yes` | `yes` loops forever. `no` plays once. |

You can combine at most two of `--start`, `--end` and `--duration`.

### Choosing dither and quality

A GIF can only hold 256 colors. `--quality` controls *which* 256 colors are chosen, and `--dither` controls *how* they are mixed to fake the colors in between.

| `--quality` | FFmpeg setting | Effect |
|-------------|----------------|--------|
| `fast` | `palettegen=stats_mode=diff` | Builds the palette mostly from the parts of the frame that change. Faster, and can miss subtle colors in static areas. |
| `default` | `palettegen` | FFmpeg's general-purpose balance. |
| `best` | `palettegen=stats_mode=full` | Analyzes every pixel of every frame. Slowest, richest colors. |

| `--dither` | FFmpeg setting | Effect |
|------------|----------------|--------|
| `none` | `paletteuse=dither=none` | No blending. Smallest and fastest, but gradients show visible bands. |
| `basic` | `paletteuse=dither=bayer:bayer_scale=5` | Ordered pattern dithering. A middle ground. |
| `best` | `paletteuse=dither=floyd_steinberg` | Error-diffusion dithering. Smoothest gradients, larger files. |

For the best-looking result use `--quality best --dither best`, which is the default. For speed and small files use `--quality fast --dither none`. GIFs are large by nature; if size matters, run the result through [`gifsicle`](https://www.lcdf.org/gifsicle/) afterwards.

**Example:**

```bash
python3 mp4_to_gif_converter.py input.mp4 output.gif --fps 15 --width 800 --start 2 --duration 5
```

---

## 3. `animate.sh`

Runs the full pipeline with default settings: PNG frames to MP4, then that MP4 to a GIF.

```bash
./animate.sh <input_folder> <output_folder>
```

1. Creates the output folder if it doesn't exist.
2. Runs `generate_video_ffmpeg.py` on the input folder. If this fails, the script stops.
3. Picks the newest `.mp4` in the output folder.
4. Runs `mp4_to_gif_converter.py` on it, writing the GIF next to the MP4.

The two Python scripts must be in the same folder as `animate.sh`. To change settings, such as quality or GIF width, edit the two `python3` lines in the script to pass extra options.

> [!TIP]
> To make videos automatically when a simulation finishes, call `animate.sh` from the post-processing section of your job script. The [STAR-CCM+ job scripts](../starccm/index.md) have a marked place for this.
