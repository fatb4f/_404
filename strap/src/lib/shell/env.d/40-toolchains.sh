if [[ -d "$HOME/.local/share/cargo" ]]; then
  export CARGO_HOME="${CARGO_HOME:-$HOME/.local/share/cargo}"
else
  export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
fi

if [[ -d "$HOME/.local/share/rustup" ]]; then
  export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.local/share/rustup}"
else
  export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
fi

if [[ -d "$CARGO_HOME/bin" ]]; then
  path_prepend "$CARGO_HOME/bin"
fi

if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

export CC="$HOME/.local/bin/gcc"
export CXX="$HOME/.local/bin/g++"
