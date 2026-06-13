# Contributing Guidelines

## Code organization

* Organize functions into files according to their purpose. If the current structure no longer reflects the intended organization, open an issue describing the proposed changes.

* Helper functions should be defined in the same file as the function that uses them. Shared helpers used by multiple files or folders may be placed in a common location.

* Helper functions should be grouped under a `# SUPPORT FUNCTIONS` section at the end of the file and should be named `_main_function_name_helper_name` (for example, `_func_helping`).

* Consider keeping small functions (like one-liners) together in one part of the file

* Keep functions focused on a single task.

* Functions that are no longer recommended but are retained for compatibility or historical reasons may be moved to `deprecated.sh` instead of being removed entirely.

* Avoid adding overly specific aliases or wrappers for common commands. Personal shortcuts (for example, using func as an alias for git status) should generally be kept in a separate file excluded from version control. Exceptions may be made for aliases and wrappers that are widely recognized and have intuitive names (for example, la for ls -A "$@"). Such exceptions are subject to community review and may be accepted or rejected based on community consensus.

* Current structure follows these rules:
 - `cli.sh` - general functions that have to do with terminal usage irrespective of any projects (like `la`, `ce` or `up`)
 - `git.sh` - anything that has to do with version control
 - `project.sh` - functions that are used on different projects or their workflows (to be split into different files as the size increases)
 - `deprecated.sh` - functions that have since been deprecated and, albeit working, shouldn't be used anymore, kept for historical and backwards compatibility uses
 - `validators.sh` - validators, it's really that simple

## Documentation

* Update the relevant man pages when adding or modifying functionality.

* Follow the general structure and conventions used by the Linux man-pages project and by the existing man pages in this repository.

* Keep section names and ordering consistent with existing man pages whenever possible. Add or remove sections only when doing so improves the documentation for a particular function.

* Every function must clearly document the shell(s) on which it is known to work. Shell-specific functionality is acceptable, but compatibility information must be provided.

* If applicable, document the minimum shell version required.

* Include examples whenever appropriate.

* Keep comments focused on explaining why something is done rather than what the code does.

* Deprecated functions should be clearly marked with `[DEPRECATED]` in the title or name section of their man pages.

* Deprecated functions should explain why they were deprecated and, when applicable, point users to a recommended replacement.

## Issues and pull requests

* Use issues to report bugs, request features, or discuss structural changes.

* Submit code changes through pull requests.

* Describe the purpose of a pull request and provide any relevant context.

* Pull requests should specify:

  * the operating system(s) used for testing;
  * the shell(s) and their versions;
  * any external dependencies required by the function.

* Link pull requests to the issues they address whenever possible.

* Discuss large or potentially disruptive changes in an issue before implementing them.

## Testing

* Test changes before opening a pull request.

* Ensure that existing functionality continues to work after your changes.

* If reporting a bug, provide enough information for others to reproduce it.

* When possible, verify functionality on more than one environment. Functions that only work on a specific operating system or shell are acceptable, provided this is documented.

## General

* Prefer readability over cleverness.

* Avoid introducing unnecessary dependencies.

* Functions intended to return data should avoid printing informational messages to stdout. Use stderr for warnings and status messages.

* Keep changes small and focused.

* Be respectful and constructive when reviewing or discussing contributions.

