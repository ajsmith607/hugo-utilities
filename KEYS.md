
# Keybyinding Index

**All keybindings are preceeded by <leader>**

## Tasks

From anywhere:

| Map     | Description                                                     |
| ------- | --------------------------------------------------------------- |
| **to**  | Open TODO.TASKS in CWD; create with section headers if missing  |
| **tn**  | Append current line or selection as a new task under NEW        |

`tn` allows you to define a new task or set of tasks in context, then move them with the keybinding to TODO.TASKS > NEW: with backreferencing the original context via `tf` below.

From current line or for selected range:

| Map     | Description                                                     |
| ------- | --------------------------------------------------------------- |
| **tb**  | Move to BACKLOG section                                         |
| **tt**  | Move to TODO section                                            |
| **td**  | Move to DONE section                                            |
| **tf**  | Follow file reference in TODO.txt                               | 

## History

From anywhere:

| Map     | Description                                                     |
| ------- | --------------------------------------------------------------- |
| **hh**  | Opens hugo-utilities/WORKFLOW.txt doc                           |
| **F2**  | Run compile-assets.sh **no leader**                             |

On current line:

| Map     | Description                                                     |
| ------- | --------------------------------------------------------------- |
| | |
| **ce**  | **C**itation **E**xplode: explode the citation into individual fields | 
| **it**  | **I**mage **T**ranscribe: Insert OCR text under the cursor line |
| | |
| **mo**  | **M**etadata **O**pen: Open *.md file indicated by the path under the cursor (such as those in fig shortcodes) |
| **iv**  | **I**mage **V**iew: within a *.md file will open the corresponding image in **FIM** or **Vimiv** |
| **ie**  | **I**mage **E**dit: within a *.md file will open the corresponding image in **Gimp** |
| | |
| **ps**  | **P**age **S**hortcode: insert the page shortcode boilerplate   |
| **pf**  | **P**age **F**ile: type-ahead search and insert the basename of the desired page file | 
| **bs**  | **B**lock **S**hortcode: insert the block shortcode boilerplate |
| **bf**  | **B**lock **F**ile: type-ahead search and insert the basename of the desired block file |
| **fs**  | **F**IG **S**hortcode: insert the fig shortcode boilerplate     |
| **ff**  | **F**IG **F**ile: type-ahead search and insert the basename of the desired metadata file for the fig |
| **fp**  | **F**igure **P**late: insert the full figure HTML skeleton      |
| | |
| **U**   | Pastes trimmed URL (no protocol or prefix)                      |
| **UU**  | Pastes trimmed URL inside parentheses                           |

