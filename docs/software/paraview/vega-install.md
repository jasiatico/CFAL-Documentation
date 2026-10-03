# Installing ParaView on Vega

This guide installs your own copy of ParaView 6.2.0 in your home directory and shows how to run `pvpython` scripts from a job, with no display needed.

> [!NOTE]
> Written October 3, 2026, using ParaView 6.2.0 (Python 3.12). Newer versions may be available on the [ParaView download page](https://www.paraview.org/download/).

---

## Why install your own?

The ParaView versions that the Vega administrators install can occasionally be buggy. Your own copy lets you choose a version you know works, keep several versions side by side, and not depend on what is installed system-wide. The download is a ready-built binary, so there is nothing to compile and no administrator access is needed.

## 1. Pick an install location

Use a folder in your home directory. Following the same convention as [Building FFmpeg on Vega](../ffmpeg/vega-compile.md):

```bash
PV="$HOME/compiled_software/paraview"
mkdir -p "$PV"
```

## 2. Download and unpack

Vega's compute nodes cannot reach the internet. Only the head (login) node can, so do the download there, not inside a job:

```bash
cd "$PV"
wget -O ParaView-6.2.0-MPI-Linux-Python3.12-x86_64.tar.gz \
  "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v6.2&type=binary&os=Linux&downloadFile=ParaView-6.2.0-MPI-Linux-Python3.12-x86_64.tar.gz"
tar -xzf ParaView-6.2.0-MPI-Linux-Python3.12-x86_64.tar.gz
rm ParaView-6.2.0-MPI-Linux-Python3.12-x86_64.tar.gz
```

The file name describes the build: **MPI** means it can run in parallel, **Python3.12** is the Python it bundles, and **x86_64** is the processor type. The bundled Python is separate from any Python module on Vega, so you do not need to load one.

## 3. Start an interactive job

The test should run on a compute node, not the shared head node. Request a short interactive session:

```bash
msub -I -q shortq -l nodes=1:ppn=4,walltime=01:00:00
```

> [!NOTE]
> The resource request above is a small example; adjust it if your setup requires other options. See [Job Submission](../../cluster/vega/getting-started/05_job_submission.md) for what each option means.

## 4. Test it

Create a file called `test_pv.py`:

```python
from paraview import simple
import paraview

print("ParaView version:", paraview.__version__)

sphere = simple.Sphere()
view = simple.CreateRenderView()
simple.Show(sphere, view)
simple.Render(view)
simple.SaveScreenshot("test.png", view)
print("Wrote test.png")
```

Then run it with your copy of `pvpython` in the interactive session. If the session started in a different shell, set `PV` again first:

```bash
PV="$HOME/compiled_software/paraview"
PV620="$PV/ParaView-6.2.0-MPI-Linux-Python3.12-x86_64/bin/pvpython"
"$PV620" test_pv.py
```

You should see `ParaView version: 6.2.0` and end up with a non-blank `test.png`.

### The "bad X server connection" warning

Without any extra setup you will probably see this warning:

```text
vtkXOpenGLRenderWindow.:1452  WARN| bad X server connection. DISPLAY=
```

Compute nodes have no display, and ParaView first tries to open a window. In testing, the images were still written correctly, so the warning is harmless. To remove it, tell ParaView to render off-screen:

```bash
export VTK_DEFAULT_OPENGL_WINDOW=vtkOSOpenGLRenderWindow
"$PV620" test_pv.py
```

This prints a message like `OSMesa not found. Fallback to bundled libOSMesa at ...`. That is expected: Vega has no system OSMesa library, so ParaView uses the one included in the download. The output is the same, with no warning.

## 5. Use it in a job script

Put the `export` line and the path to `pvpython` in your job script. Note the `$` and the quotes when you call it; writing `PV620 script.py` without the `$` will not work.

```bash
#PBS -S /bin/bash
#PBS -q shortq
#PBS -l walltime=01:00:00
#PBS -l nodes=1:ppn=4
#PBS -N paraview_render

cd $PBS_O_WORKDIR

export VTK_DEFAULT_OPENGL_WINDOW=vtkOSOpenGLRenderWindow

PV="$HOME/compiled_software/paraview"
PV620="$PV/ParaView-6.2.0-MPI-Linux-Python3.12-x86_64/bin/pvpython"

"$PV620" my_script.py
```

> [!TIP]
> When you install another version later, unpack it next to this one and add a second variable (for example `PV630`). Old scripts keep working with the version they were written for.

---

Next: turn the rendered images into a video with [FFmpeg](../ffmpeg/index.md).
