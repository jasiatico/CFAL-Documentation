# FFmpeg

FFmpeg is an open-source tool for converting and encoding video. In the lab we mostly use it to turn image sequences exported from a simulation (for example, one PNG per time step from STAR-CCM+) into MP4 videos and GIFs for presentations and papers.

---

## Guides

| Guide | What it covers |
|-------|----------------|
| [Building FFmpeg on Vega](./vega-compile.md) | Compiling FFmpeg with H.264 support into your home directory, for when Vega's installed FFmpeg can't write `.mp4` files |
| [Image Sequences to Video](./video-scripts.md) | Using the lab's scripts to turn a folder of PNG frames into an MP4 and a GIF |

## Scripts

| Script | What it does |
|--------|--------------|
| [`generate_video_ffmpeg.py`](./scripts/generate_video_ffmpeg.py) | Converts a folder of PNG frames into an H.264 MP4 |
| [`mp4_to_gif_converter.py`](./scripts/mp4_to_gif_converter.py) | Converts an MP4 into an optimized GIF |
| [`animate.sh`](./scripts/animate.sh) | Runs both scripts in a row: PNG frames in, MP4 and GIF out |

The scripts work anywhere FFmpeg is installed with H.264 support, including your own computer. On Vega, check [Building FFmpeg on Vega](./vega-compile.md) first.
