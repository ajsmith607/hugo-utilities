#!/bin/bash


check_file() {
    local file="${1-}"
    if [[ -n "$file" ]]; then
        if [[ ! -f "$file" ]]; then
            echo "Error: File not found: $file" >&2
            exit 1
        fi
    fi
}


# --------------------------------------------------------------
# run command on images
#   $1..$n-1 : command + its args (passed through)
#   $n       : path (file or cwd)
# --------------------------------------------------------------
run_on_images() {
    local -a cmd=()          # command + args before filename
    local path="."           # default: cwd

    # Parse args: last one is path, rest are command
    while (( $# > 1 )); do
        cmd+=("$1")
        shift
    done
    path="$1"

    # If path is a file → run once
    if [[ -f "$path" ]]; then
        "${cmd[@]}" "$path"
        return
    fi

    # Otherwise, assume cwd or dir → recurse
    if [[ ! -d "$path" ]]; then
        printf "Error: Path not found: %s\n" "$path" >&2
        exit 1
    fi

    (cd "$path" && find . -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 |
        while IFS= read -r -d '' file; do
            "${cmd[@]}" "$file"
        done
    )
}

