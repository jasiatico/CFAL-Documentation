
# 🎞️ Compiling FFmpeg with x264 Support on the HPC Cluster  
## Section: Building FFmpeg from Source with libx264 (July 16, 2025)

FFmpeg is a powerful open-source multimedia framework used for video and audio encoding, decoding, transcoding, and streaming. In our research environment, FFmpeg is often used to generate video output from simulation data or image sequences.

## 🧭 Purpose of This Guide

Although FFmpeg is available on the cluster, **it is not built with x264 support** by default as of **July 16, 2025**. This means you cannot encode videos in the widely-used H.264 format unless you build FFmpeg yourself.

This guide walks you through compiling both **x264** and **FFmpeg** from source and installing them into your home directory.

## ⚙️ Prerequisites

Make sure the cluster environment supports the following tools via modules:

- `gcc` (C compiler)
- `yasm` and `nasm` (assembly compilers)

These should be already installed on the cluster and should work as of the posted date.

## 🛠️ Steps to Compile FFmpeg with x264

Run the following commands interactively on the **head node**:

### 1️⃣ Load Required Modules

```bash
module purge
module load gcc
module load yasm
module load nasm
```

Check that `yasm` and `nasm` are available (this step isn't needed, but is just a double check):

```bash
yasm --version
nasm --version
```

### 2️⃣ Define Installation Path

Pick an installation directory in your home folder (you can change this path):

```bash
INSTALL_DIR="$HOME/compiled_software/FFmpeg"
echo $INSTALL_DIR
```

### 3️⃣ Build x264

```bash
mkdir -p "$INSTALL_DIR/x264_build/src"
cd "$INSTALL_DIR/x264_build/src"
git clone --depth 1 https://code.videolan.org/videolan/x264.git
cd x264
./configure --prefix="$INSTALL_DIR/x264_build" --enable-static --enable-pic
make -j$(nproc)
make install
```

Check that the build succeeded:

```bash
ls "$INSTALL_DIR/x264_build/bin"
```

You should see an `x264` binary there.

### 4️⃣ Build FFmpeg with x264 Support

```bash
cd "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/FFmpeg_build/src"
cd "$INSTALL_DIR/FFmpeg_build/src"
git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git
cd FFmpeg

export PKG_CONFIG_PATH="$INSTALL_DIR/x264_build/lib/pkgconfig:$PKG_CONFIG_PATH"

./configure --prefix="$INSTALL_DIR/FFmpeg_build"   --pkg-config-flags="--static"   --extra-cflags="-I$INSTALL_DIR/x264_build/include"   --extra-ldflags="-L$INSTALL_DIR/x264_build/lib"   --enable-gpl --enable-libx264 --enable-static --disable-shared

make -j$(nproc)
make install
```

### ✅ Final Notes

Check that your compiled FFmpeg binary was created:

```bash
ls $INSTALL_DIR/FFmpeg_build/bin/ffmpeg
```

You can run it directly using the full path (**not preferred**):

```bash
$INSTALL_DIR/FFmpeg_build/bin/ffmpeg -i input_frames/%04d.png -c:v libx264 output.mp4
```

Or, to make it easier to use, you can add it to your `PATH` so you can just type `ffmpeg` from any directory (**preferred**):

### ➕ Add FFmpeg to Your PATH

Append this line to your `~/.bashrc`:

```bash
grep -qxF 'export PATH="$INSTALL_DIR/FFmpeg_build/bin:$PATH"' ~/.bashrc || echo 'export PATH="$INSTALL_DIR/FFmpeg_build/bin:$PATH"' >> ~/.bashrc
```

Then reload your shell configuration:

```bash
source ~/.bashrc
```

Now you can simply run:

```bash
ffmpeg -i input_frames/%04d.png -c:v libx264 output.mp4
```

From anywhere in your terminal session.

---

This setup ensures full `libx264` support and can be reused or versioned across projects.

Full usage details and integration tips will be provided in the next sections.
