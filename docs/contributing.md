# Contributing

This handbook is written by lab members, for lab members. If something is wrong, out of date or missing, please fix it. Many pages are still marked "Draft in progress", and filling one in is one of the most useful things you can do for the next person who joins the lab.

---

## Small fixes

For a typo, a broken link or an outdated command, you can edit the page directly on GitHub. No setup is needed.

1. Click the **edit** icon (the pencil) at the top right of the page you want to change.
2. GitHub opens the page's Markdown source. Make your change.
3. At the bottom, describe what you changed and choose **Propose changes**. If you don't have write access to the repository, GitHub makes a copy (a *fork*) for you automatically.
4. Open the pull request. It will be reviewed and merged.

## Larger changes

For a new page, a new section or anything involving images or scripts, work on your own computer so you can preview the site as you go.

### 1. Get the source and install MkDocs

```bash
git clone https://github.com/jasiatico/CFAL-Documentation.git
cd CFAL-Documentation
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
```

### 2. Preview the site

```bash
.venv/bin/mkdocs serve
```

Open the address it prints (usually `http://127.0.0.1:8000/CFAL-Documentation/`). The page reloads every time you save a file.

### 3. Make your change on a branch

```bash
git checkout -b <short-description-of-change>
```

Edit or add files under `docs/`. If you add a page, also add it to the `nav:` list in `mkdocs.yml` and link it from its section's overview table.

### 4. Check the build

```bash
.venv/bin/mkdocs build --strict
```

This must finish without warnings. Strict mode catches broken links and pages that are missing from the navigation, and the same check runs automatically on GitHub before the site is published.

### 5. Open a pull request

Push your branch and open a pull request against `main`. In the description, say what you changed and why.

---

## Where things go

All site content lives in `docs/`, and each folder matches a section in the navigation.

| Content | Location |
|---------|----------|
| Joining the lab, accounts, expectations | `docs/getting-started/` |
| Undergraduate and graduate guidance | `docs/undergraduate/`, `docs/graduate/` |
| Writing, LaTeX, figures, reviews | `docs/writing/` |
| Equipment, licenses, data, policies | `docs/lab/` |
| Vega itself: access, jobs, hardware | `docs/cluster/vega/` |
| A specific tool, including running it on Vega | `docs/software/<tool>/` |

A few rules keep this organized:

- **Scripts live with the page that explains them**, in a `scripts/` folder next to it. A job script for running a tool on Vega belongs to that tool's section (for example `docs/software/starccm/scripts/`), not to the Vega section.
- **Pages about running a tool on Vega** start with `vega-`, for example `vega-single-case.md`.
- **Images** go in an `images/` folder next to the pages that use them. Images used across the whole site go in `docs/assets/images/`.

---

## Writing a page

- **Title and intro.** Start with a single `#` title, then one or two sentences saying what the page covers and who it's for.
- **Structure.** Use `##` headings for sections, numbered (`## 1. …`) for step-by-step guides, and separate major parts with a `---` line.
- **Callouts.** Use GitHub-style callouts for notes and warnings. They display correctly both on this site and on GitHub:

    ```markdown
    > [!NOTE]
    > Connecting to Vega from off campus requires the VPN.

    > [!WARNING]
    > Scratch space is not backed up.
    ```

- **Code blocks.** Always give the language (`bash`, `python`, and so on) so they get syntax highlighting and a copy button.
- **Date anything that can change.** Module names, software versions, limits and cluster settings go out of date. Write "As of July 2025, …" so readers know how fresh the information is.
- **Scripts must match their docs.** If a page describes a script's options or defaults, check them against the script itself. When they disagree, the script is right and the page should be fixed.
- **Write for someone new.** Explain terms a first-semester lab member might not know, and avoid unexplained shorthand.

### Starting a placeholder page

If you want to reserve a page for later, use the same placeholder as the rest of the site:

```markdown
# Page Title

One sentence describing what this page will cover.

!!! note "Draft in progress"
    This section is coming soon. Want to help? See [Contributing](../contributing.md).
```

---

## Licensing

By contributing, you agree that your documentation is shared under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) and your scripts under the MIT License, the same as the rest of the repository.
