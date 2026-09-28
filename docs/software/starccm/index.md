# STAR-CCM+

STAR-CCM+ is the commercial CFD package from Siemens that most lab projects use. This section covers running it in batch mode on Vega, with ready-to-edit job scripts for the two most common workflows.

To see which versions are installed on Vega, run `module avail starccm` or check the [Vega Hardware Reference](../../cluster/vega/reference/vega_hardware.md).

---

## Running on Vega

| Guide | Use it when | Job script |
|-------|-------------|------------|
| [Single Case](./vega-single-case.md) | You are running one `.sim` file with one set of conditions, or testing a setup before scaling up | [`single_case.sh`](./scripts/single_case.sh) |
| [Design Manager](./vega-design-manager.md) | You are running a parameter sweep, design of experiments or optimization study from a `.dmprj` project | [`design_manager.sh`](./scripts/design_manager.sh) |

Both scripts follow the same pattern: copy your inputs to scratch space, run there, then copy results back to your home directory and clean up. The [Job Submission](../../cluster/vega/getting-started/05_job_submission.md) page explains why.
