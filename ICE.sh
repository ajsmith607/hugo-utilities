#!/bin/bash
#======================================================================
# ICE.sh — Interactive Configuration Environment (ICE) for Bash
#----------------------------------------------------------------------
# Drop-in library to make Bash scripts self-documenting and interactive.
#
#   Features:
#     • Quiet-by-default configuration management
#     • Optional editing via -e / --edit
#     • Auto-generated man page (~/.local/share/man/man1/)
#     • Shared single-source documentation for help + man
#     • No setup required in app: call ice_run "$@"
#
#   Integration:
#     1. In your script:
#          source ~/bin/ICE.sh && ice_run "$@" || exit 1
#     2. Optionally define:
#          myapp_doc   — custom help text (optional), defined in main script
#          myapp.template — optional template file, located in same directory as main script
#======================================================================

#----------------------------------------------------------------------
# Default documentation text
#----------------------------------------------------------------------

set -Eeuo pipefail

# cleanly exit on Ctrl-C
trap 'echo; echo "Cancelled by user."; exit 1' INT

ice_default_doc=$(cat <<'EOF'
Usage: APPNAME.sh [options]

APPNAME — an Interactive Configuration Environment (ICE) script.

Default (quiet) mode:
  • Loads configuration from .APPNAME.conf if present
  • Otherwise copies APPNAME.template (if available) to .APPNAME.conf
  • Runs silently using defaults

Options:
  -h, --help     Show this help message.
  -e, --edit     Edit configuration interactively, then continue.

For detailed instructions, run:  man APPNAME
EOF
)


#----------------------------------------------------------------------
# ice_print_help
#----------------------------------------------------------------------
ice_print_help() {
    local appname="$1"
    local appdate="$2"
    local docvar="${appname}_doc"
    local doctext="${!docvar:-$ice_default_doc}"
    doctext="${doctext//APPNAME/$appname}"
    doctext="${doctext//APPDATE/$appdate}"
    echo "$doctext"
}


#----------------------------------------------------------------------
# ice_generate_man
#----------------------------------------------------------------------
ice_generate_man() {
    local appname="$1"
    local script_path="$2"
    local appdate="$3"

    local mandir="$HOME/.local/share/man/man1"
    local manfile="${mandir}/${appname}.1"
    local gzfile="${manfile}.gz"

    mkdir -p "$mandir" || return 1

    if [[ ! -f "$gzfile" || "$script_path" -nt "$gzfile" ]]; then
        echo "Updating manual page for ${appname}..."
        local helptext
        helptext="$(ice_print_help "$appname" "$appdate")"

        cat >"$manfile" <<EOF
.TH "${appname}" 1 "$(date +"%B %Y")" "${appname} utility" "User Commands"
.SH NAME
${appname} \- interactive configuration environment (ICE) script
.SH SYNOPSIS
.B ${appname}.sh
[\-h|\-\-help]
[\-e|\-\-edit]
.SH DESCRIPTION
$(echo "$helptext" | sed 's/^/    /')
.SH FILES
    .${appname}.conf        user configuration
    ${appname}.template     default configuration template
.SH DATE
    ${appdate}
.SH AUTHOR
    Automatically generated from ${script_path}
EOF

        gzip -f "$manfile"
    fi

    case ":$MANPATH:" in
        *":$HOME/.local/share/man:"*) ;;
        *) export MANPATH="$HOME/.local/share/man:$MANPATH" ;;
    esac
}


#----------------------------------------------------------------------
# ice_edit_and_confirm
# Unified edit + continue/cancel confirmation step.
#----------------------------------------------------------------------
ice_edit_and_confirm() {
    local editor="${EDITOR:-vi}"
    local config_file="$1"

    "$editor" "$config_file"
    echo
    echo "Press ENTER to continue, or Ctrl+C to cancel..."
    read -r _
}


#----------------------------------------------------------------------
# ice_init_config
#----------------------------------------------------------------------
ice_init_config() {
    local appname="$1"
    local mode="${2:-quiet}"
    local config_file=".${appname}.conf"

    # Template co-located with app script
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    local template_file="${script_dir}/${appname}.template"

    if [[ ! -f "$config_file" ]]; then
        echo "No existing config file found."
        if [[ -f "$template_file" ]]; then
            echo "Using template: $template_file"
            cp "$template_file" "$config_file"
        else
            echo "Creating minimal guided config."
            cat >"$config_file" <<'EOF'
#-------------------------------------------------------------------
# Example configuration file
# Define parameters using Bash syntax:
# VAR="value"
# Lines starting with # are comments.
#-------------------------------------------------------------------

EOF
        fi

        [[ "$mode" == "edit" ]] && ice_edit_and_confirm "$config_file"

    elif [[ "$mode" == "edit" ]]; then
        ice_edit_and_confirm "$config_file"
    fi

    if [[ -f "$config_file" ]]; then
        # shellcheck source=/dev/null
        source "$config_file"
    fi
}


#----------------------------------------------------------------------
# ice_run
#----------------------------------------------------------------------
ice_run() {
    local script_path="$0"
    local appname
    appname="$(basename "$script_path" .sh)"
    local appdate
    appdate="$(date +%Y-%m-%d)"
    local mode="quiet"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                ice_print_help "$appname" "$appdate"
                return 10
                ;;
            -e|--edit)
                mode="edit"
                ;;
            *)
                echo "Unknown option: $1" >&2
                ice_print_help "$appname" "$appdate"
                return 1
                ;;
        esac
        shift
    done

    ice_generate_man "$appname" "$script_path" "$appdate"
    ice_init_config "$appname" "$mode"

    echo "Configuration loaded for ${appname}."
    return 0
}



