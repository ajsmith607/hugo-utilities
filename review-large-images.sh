#!/bin/bash
# usage:
#   ./checksizes.sh                 # all files, default 5M threshold
#   ./checksizes.sh myfile.jpg      # single file, default 5M threshold
#   ./checksizes.sh myfile.jpg 10M  # single file, custom threshold
#   ./checksizes.sh 10M             # all files, custom threshold

to_bytes() {
    local size=$1
    case "$size" in
        *M) echo $(( ${size%M} * 1024 * 1024 ));;
        *K) echo $(( ${size%K} * 1024 ));;
        *)  echo "$size";;
    esac
}

# --- Argument handling ---
THRESHOLD="5M"
if [[ $# -eq 0 ]]; then
    MODE="multi"
elif [[ $# -eq 1 ]]; then
    if [[ -f "$1" ]]; then
        MODE="single"
        FILE="$1"
    fi
elif [[ $# -ge 2 ]]; then
    MODE="single"
    FILE="$1"
    THRESHOLD="$2"
fi

THRESHOLD_BYTES=$(to_bytes "$THRESHOLD")
BATCHSIZE="${3:-5}"

# --- Single file mode ---
if [[ $MODE == "single" ]]; then
    echo "Checking single file: $FILE (threshold: $THRESHOLD)"
    if [[ ! -f "$FILE" ]]; then
        echo "Error: File not found: $FILE"
        exit 1
    fi
    size=$(stat -c%s "$FILE")
    if (( size > THRESHOLD_BYTES )); then
        echo "File exceeds threshold ($(du -h "$FILE" | cut -f1)). Opening in GIMP."
        gimp "$FILE"
    else
        echo "File under threshold ($((size / 1024)) KB)."
    fi
    exit 0
fi

echo "Threshold: $THRESHOLD"
# --- Multi-file mode ---
mapfile -t FILES < <(
    find . -type f \( -iname '*.jpg' -o -iname '*.png' \) -size +"$THRESHOLD" \
        -printf '%s\t%p\n' | sort -n | cut -f2
)

COUNT=${#FILES[@]}
echo "There are $COUNT files over $THRESHOLD."

if (( COUNT > 0 )); then
    echo "Processing in batches of $BATCHSIZE."
    for ((i=0; i<COUNT; i+=BATCHSIZE)); do
        batch=( "${FILES[@]:i:BATCHSIZE}" )
        echo "Opening batch $((i/BATCHSIZE+1)): ${batch[*]}"
        gimp "${batch[@]}"
        echo "Closed batch $((i/BATCHSIZE+1))."
    done
fi
