# KEQING-SHELL DEVELOPMENT CONVENTIONS

## What is this?
- A set of conventions used when developing the shell.
- It keeps the source code clean and consistent.

## Formatting the shell
Command: `/usr/lib/qt6/bin/qmlformat --normalize --single-line-empty-objects --inplace`

**IMPORTANT:** Remove `--normalize` when formatting the following files:
- `**Config.qml`
- `shell.qml`

## QML coding style
- Do not use leading underscores for id naming, or else the formatter will faill (e.g., `id: myItem`, not `id: _my_item`).
- `pragma ComponentBehavior: Bound` enables safe parent scoping.
- `qmldir` is not implemented, only `import qs.path.to.dir.contains.file`.
- Add one blank line separating library imports and local module imports for all files.
- Icons must be written as `"\uXXXX"`, do not render them.

## QML commenting style
- Add one-word comment before major code blocks to show which part it represents.
- `**Config.qml`: grouping comments required to separate sections.
- Non-config files: no comments unless the WHY is non-obvious.

## Tooling rules
- Never use awk to deduplicate imports or lines, it silently drops identical closing braces and corrupts file structure.
- Use targeted find-and-replace to remove specific lines.