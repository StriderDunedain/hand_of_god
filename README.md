# Hand of God

A collection of shell functions intended to make day-to-day work a little more convenient.

Originally started as a personal collection, Hand of God aims to provide a growing set of reusable utilities for different workflows and environments. Functions are grouped according to their purpose, and shell-specific functionality is welcome as long as its requirements and compatibility are documented.

The project is intended to be flexible rather than prescriptive: users are encouraged to adapt the provided functions to suit their own needs.

If you would like to contribute, please refer to `CONTRIBUTE.md` for the project's guidelines and conventions.

---

## Installation

Clone the repository:

```shell
git clone https://github.com/StriderDunedain/hand_of_god.git
```

Some functions (such as `refresh` and `pr`) assume that your projects are organized under a common parent directory (for example, `~/dev`). This layout is currently used throughout the project.

The following variables should be defined in your shell configuration file (`.bashrc`, `.zshrc`, etc.):

* `WORK_DIR` — the directory containing your projects. This variable is required.
* `HOD_INIT` — the absolute path to Hand of God's `init.sh`. This variable is required.
* `CURRENT_PROJECT` — an optional variable indicating the project you are currently working on. Used by functions such as `cpr`.
* `EVAL_PATH` — an optional, 42-specific variable pointing to the directory where evaluations are performed.
* `MAN_PATH` — normally detected automatically and should not need to be modified. If necessary, it may be overridden manually.

Example:

```shell
# e.g. .zshrc
export WORK_DIR="$HOME/dev"
export HOD_INIT="$WORK_DIR/hand_of_god/init.sh"
export CURRENT_PROJECT="$WORK_DIR/python/module03"
export EVAL_PATH="$WORK_DIR/evals"
```

Restart your shell (or source your configuration file again) and you're ready to go.

### Optional Setup

#### `pr`

The `pr` function requires `fzf`.

#### `adv`

The `adv` function may be customized through the following arrays:

* `ADV_PREFIX` — the prefix used when naming folders.
* `ADV_WIDTH` — the width used when numbering folders.
* `ADV_NAME_REQUIRED` — whether `adv` requires a filename when creating the next item. Defaults to false.

Example:

```shell
ADV_PREFIX[$CURRENT_PROJECT]="ex"
ADV_WIDTH[$CURRENT_PROJECT]=1
ADV_NAME_REQUIRED[$CURRENT_PROJECT]=1
```

These values may be defined independently for as many projects as desired.

---

## Man Pages

Hand of God ships with man pages for its functions.

Install them with:

```shell
mv man_pages/* ~/.local/share/man/man1
```

After installation, use:

```shell
man <function_name>
```

to view a function's manual page.

Man pages contain usage information, examples, dependencies, and shell compatibility notes.

---

## Contributing

Issues, suggestions, and pull requests are always welcome.

Whether you are fixing a bug, adding a new function, improving documentation, or proposing structural changes, please read `CONTRIBUTE.md` before contributing.

---

## Afterwords

Hand of God is not intended to be a framework or a strict standard. It is simply a collection of practical shell functions that others may find useful.

Not every function is expected to work on every shell or operating system. Shell-specific implementations are perfectly acceptable, provided their requirements and compatibility are documented.

Feel free to use, modify, and adapt these functions to your heart's content. Hopefully, some of them will make your own command-line experience a little easier.
