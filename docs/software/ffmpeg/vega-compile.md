# Building FFmpeg on Vega

This guide compiles FFmpeg with H.264 support and installs it into your home directory, so you can make `.mp4` videos on Vega.

> [!NOTE]
> Written July 16, 2025. Module names and the state of Vega's installed FFmpeg may have changed since then.

---

## Why build it yourself?

H.264 is the video format behind most `.mp4` files. It gives a good balance of quality and file size, and it plays in nearly every media player, browser and slide deck. FFmpeg can only *write* H.264 video if it was built with the **x264** library. Without x264 it can still read H.264 files, but trying to create an `.mp4` will fail or fall back to a less efficient format.

As of July 16, 2025, the FFmpeg installed on Vega was **not** built with x264. The steps below build x264 and FFmpeg from source and install both under your home directory. No administrator access is needed.

## 1. Check whether you need this

Before building anything, check whether Vega's FFmpeg can encode H.264 now:

```bash
module avail ffmpeg
module load <ffmpeg-module-from-the-list>
ffmpeg -hide_banner -encoders | grep libx264
```

If that prints a line containing `libx264`, the installed FFmpeg already works and you can skip the rest of this page. If it prints nothing, continue.

## 2. Load the build tools

You need a C compiler (`gcc`) and two assemblers (`yasm` and `nasm`), which were available as modules on Vega as of the date above. Run these on the login node:

```bash
module purge
module load gcc
module load yasm
module load nasm
```

Optionally, confirm the assemblers loaded:

```bash
yasm --version
nasm --version
```

## 3. Choose an install location

Pick a folder in your home directory. You can change this path, but use the same value for every step below:

```bash
INSTALL_DIR="$HOME/compiled_software/FFmpeg"
echo $INSTALL_DIR
```

## 4. Build x264

```bash
mkdir -p "$INSTALL_DIR/x264_build/src"
cd "$INSTALL_DIR/x264_build/src"
git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
./configure --prefix="$INSTALL_DIR/x264_build" --enable-static --enable-pic
make -j 8
make install
```

> [!TIP]
> `make -j 8` compiles with 8 parallel processes. The build takes a few minutes and is light enough for the login node, but keep the count modest because the login node is shared by everyone.

Check that the build worked. You should see an `x264` binary:

```bash
ls "$INSTALL_DIR/x264_build/bin"
```

## 5. Build FFmpeg with x264 support

```bash
mkdir -p "$INSTALL_DIR/FFmpeg_build/src"
cd "$INSTALL_DIR/FFmpeg_build/src"
git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

export PKG_CONFIG_PATH="$INSTALL_DIR/x264_build/lib/pkgconfig:$PKG_CONFIG_PATH"

./configure --prefix="$INSTALL_DIR/FFmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$INSTALL_DIR/x264_build/include" \
  --extra-ldflags="-L$INSTALL_DIR/x264_build/lib" \
  --enable-gpl --enable-libx264 --enable-static --disable-shared

make -j 8
make install
```

Check that the FFmpeg binary was created:

```bash
ls "$INSTALL_DIR/FFmpeg_build/bin/ffmpeg"
```

## 6. Add FFmpeg to your PATH

You could run FFmpeg by its full path every time:

```bash
$INSTALL_DIR/FFmpeg_build/bin/ffmpeg -i input_frames/%04d.png -c:v libx264 output.mp4
```

It's easier to add it to your `PATH`, so typing `ffmpeg` in any folder runs your build. This appends the right line to your `~/.bashrc`:

```bash
echo "export PATH=\"${INSTALL_DIR}/FFmpeg_build/bin:\$PATH\"" >> ~/.bashrc
source ~/.bashrc
```

Confirm that `ffmpeg` now points at your build and can encode H.264:

```bash
which ffmpeg
ffmpeg -hide_banner -encoders | grep libx264
```

Now you can run it from anywhere:

```bash
ffmpeg -i input_frames/%04d.png -c:v libx264 output.mp4
```

---

Next: [Image Sequences to Video](./video-scripts.md)
