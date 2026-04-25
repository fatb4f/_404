path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_prepend "${_404_TOOL_PATH:-${XDG_DATA_HOME:-$HOME/.local/share}/_404/path}"
path_prepend "$HOME/.local/bin"

export PATH
