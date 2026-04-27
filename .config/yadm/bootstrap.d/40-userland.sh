#!/usr/bin/env bash

artifact_rows() {
  local manifest=${1:?manifest}
  jq -r '
    .artifacts[]
    | select((.enabled // true) == true)
    | [
        .name,
        .repo,
        (.ref // "latest"),
        .pkg,
        (.install // "bin"),
        (.opt // .name),
        (.bins | join(","))
      ]
    | @tsv
  ' "$manifest"
}

download_release_artifact() {
  local repo=${1:?repo} ref=${2:?ref} pkg=${3:?pkg} dest_dir=${4:?dest_dir}

  ensure_dir "$dest_dir"

  if [[ -n "$ref" && "$ref" != latest ]]; then
    run gh release download -R "$repo" "$ref" --pattern "$pkg" --dir "$dest_dir"
  else
    run gh release download -R "$repo" --pattern "$pkg" --dir "$dest_dir"
  fi
}

download_source_archive() {
  local repo=${1:?repo} ref=${2:?ref} dest=${3:?dest}

  ensure_dir "$(dirname -- "$dest")"
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] curl -fsSL -o %q https://github.com/%s/archive/refs/tags/%s.tar.gz\n' "$dest" "$repo" "$ref"
    return 0
  fi

  curl -fsSL -o "$dest" "https://github.com/$repo/archive/refs/tags/$ref.tar.gz"
}

extract_artifact() {
  local artifact=${1:?artifact} dest=${2:?dest}
  ensure_dir "$dest"

  case "$artifact" in
    *.tar.gz|*.tgz)
      run tar -C "$dest" -xzf "$artifact"
      ;;
    *.tar.xz|*.txz)
      run tar -C "$dest" -xJf "$artifact"
      ;;
    *.tar.zst|*.tzst)
      run tar -C "$dest" --zstd -xf "$artifact"
      ;;
    *.zip)
      if [[ "${DRY_RUN:-0}" == 1 ]]; then
        printf '[dry-run] unzip -q %q -d %q\n' "$artifact" "$dest"
      else
        unzip -q "$artifact" -d "$dest"
      fi
      ;;
    *)
      if [[ "${DRY_RUN:-0}" == 1 ]]; then
        printf '[dry-run] cp %q %q/\n' "$artifact" "$dest"
      else
        cp -- "$artifact" "$dest/"
      fi
      ;;
  esac
}

find_one_artifact() {
  local dir=${1:?dir}
  local count first

  count="$(find "$dir" -maxdepth 1 -type f | wc -l | tr -d ' ')"
  [[ "$count" == 1 ]] || die "expected exactly one downloaded artifact in $dir, found $count"

  first="$(find "$dir" -maxdepth 1 -type f | head -n 1)"
  [[ -n "$first" ]] || die "downloaded artifact missing in $dir"
  printf '%s\n' "$first"
}

find_bin_in_tree() {
  local tree=${1:?tree} bin=${2:?bin}
  local found
  local -a matches=()
  local -a preferred=()

  while IFS= read -r found; do
    [[ -n "$found" ]] || continue
    matches+=("$found")
    case "$found" in
      "$tree"/bin/"$bin")
        preferred+=("$found")
        ;;
    esac
  done < <(find "$tree" \( -type f -o -type l \) -name "$bin" 2>/dev/null)

  if [[ "${#preferred[@]}" == 1 ]]; then
    printf '%s\n' "${preferred[0]}"
    return 0
  fi

  if [[ "${#preferred[@]}" -gt 1 ]]; then
    die "expected exactly one primary binary named $bin in $tree/bin, found ${#preferred[@]}"
  fi

  [[ "${#matches[@]}" == 1 ]] || die "expected exactly one binary named $bin in $tree, found ${#matches[@]}"
  printf '%s\n' "${matches[0]}"
}

source_tree_root() {
  local tree=${1:?tree}
  local -a dirs=()
  local dir

  while IFS= read -r dir; do
    [[ -n "$dir" ]] || continue
    dirs+=("$dir")
  done < <(find "$tree" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

  if [[ "${#dirs[@]}" == 1 ]]; then
    printf '%s\n' "${dirs[0]}"
    return 0
  fi

  printf '%s\n' "$tree"
}

release_pattern_matches_latest() {
  local repo=${1:?repo} pkg=${2:?pkg}
  local asset matched=0
  local payload

  payload="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest")"
  while IFS= read -r asset; do
    [[ -n "$asset" ]] || continue
    if [[ "$asset" == $pkg ]]; then
      matched=1
      break
    fi
  done < <(printf '%s\n' "$payload" | jq -r '.assets[].name')

  [[ "$matched" == 1 ]] || die "no latest release asset in $repo matches $pkg"
}

install_selected_bins() {
  local extracted=${1:?extracted} bin_dir=${2:?bin_dir} bins_csv=${3:?bins_csv}
  local IFS=','
  local bin found

  ensure_dir "$bin_dir"
  for bin in $bins_csv; do
    found="$(find_bin_in_tree "$extracted" "$bin")"

    if [[ "${DRY_RUN:-0}" == 1 ]]; then
      printf '[dry-run] install -m 0755 %q %q\n' "$found" "$bin_dir/$bin"
    else
      install -m 0755 -- "$found" "$bin_dir/$bin"
    fi
  done
}

install_opt_tree_and_links() {
  local extracted=${1:?extracted} opt_root=${2:?opt_root} opt_name=${3:?opt_name} bin_dir=${4:?bin_dir} bins_csv=${5:?bins_csv}
  local install_root="$opt_root/$opt_name"
  local new_root="$install_root.new"
  local IFS=','
  local bin found

  ensure_dir "$opt_root"
  ensure_dir "$bin_dir"

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] rm -rf %q\n' "$new_root"
    printf '[dry-run] mkdir -p %q\n' "$new_root"
    printf '[dry-run] cp -a %q/. %q/\n' "$extracted" "$new_root"
    printf '[dry-run] rm -rf %q\n' "$install_root"
    printf '[dry-run] mv %q %q\n' "$new_root" "$install_root"
  else
    rm -rf -- "$new_root"
    mkdir -p -- "$new_root"
    cp -a -- "$extracted/." "$new_root/"
    rm -rf -- "$install_root"
    mv -- "$new_root" "$install_root"
  fi

  for bin in $bins_csv; do
    if [[ "${DRY_RUN:-0}" == 1 ]]; then
      printf '[dry-run] ln -sfn <resolved:%s under %s> %q\n' "$bin" "$install_root" "$bin_dir/$bin"
      continue
    fi

    found="$(find_bin_in_tree "$install_root" "$bin")"
    chmod 0755 -- "$found" 2>/dev/null || true
    ln -sfn -- "$found" "$bin_dir/$bin"
  done
}

install_userland_tools() {
  local manifest=${1:?manifest}
  local cache_home=${XDG_CACHE_HOME:-$HOME/.cache}
  local state_home=${XDG_STATE_HOME:-$HOME/.local/state}
  local bin_dir=${USERLAND_BIN:-$HOME/.local/bin}
  local opt_root=${USERLAND_OPT_HOME:-$HOME/.local/opt}
  local cache_root=${USERLAND_ARTIFACT_CACHE:-$cache_home/userland/artifacts}
  local receipt=${USERLAND_RECEIPT:-$state_home/userland/installed.tsv}
  local receipt_tmp=

  if [[ "${DRY_RUN:-0}" != 1 ]]; then
    require_cmd gh curl jq tar unzip find head install cp ln chmod || die 'missing required userland installer command'
  fi

  ensure_dir "$bin_dir"
  ensure_dir "$opt_root"
  ensure_dir "$cache_root"
  ensure_dir "$(dirname -- "$receipt")"
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    receipt_tmp="${receipt}.dryrun.$$"
  else
    receipt_tmp="$(mktemp "${receipt}.XXXXXX")"
  fi

  local rows=()
  local row name repo ref pkg strategy opt bins_csv first_bin tmp artifact extracted
  mapfile -t rows < <(artifact_rows "$manifest")

  for row in "${rows[@]}"; do
    [[ -n "$row" ]] || continue
    IFS=$'\t' read -r name repo ref pkg strategy opt bins_csv <<< "$row"

    [[ -n "$name" && -n "$repo" && -n "$strategy" && -n "$bins_csv" ]] \
      || die "bad userland artifact row: $row"

    first_bin=${bins_csv%%,*}
    if [[ -e "$bin_dir/$first_bin" && "${FORCE:-0}" != 1 ]]; then
      info "userland present: $name -> $bin_dir/$first_bin"
      continue
    fi

    if [[ "${DRY_RUN:-0}" == 1 ]]; then
      tmp="$cache_root/.tmp.$name.DRYRUN"
      extracted="$tmp/extract"
      artifact="$tmp/<downloaded-artifact>"
      info "would install $name from $repo"
      printf '[dry-run] jq -r %q %q\n' '.artifacts[] | select((.enabled // true) == true) | [.name,.repo,(.ref // "latest"),.pkg,(.install // "bin"),(.opt // .name),(.bins | join(","))] | @tsv' "$manifest"
      case "$strategy" in
        bin)
          printf '[dry-run] gh release download -R %q %q --pattern %q --dir %q\n' "$repo" "$ref" "$pkg" "$tmp"
          printf '[dry-run] extract %q into %q\n' "$artifact" "$extracted"
          printf '[dry-run] install bins %q into %q\n' "$bins_csv" "$bin_dir"
          ;;
        opt)
          printf '[dry-run] gh release download -R %q %q --pattern %q --dir %q\n' "$repo" "$ref" "$pkg" "$tmp"
          printf '[dry-run] extract %q into %q\n' "$artifact" "$extracted"
          printf '[dry-run] install opt tree %q into %q and symlink bins %q into %q\n' "$opt" "$opt_root" "$bins_csv" "$bin_dir"
          ;;
        source)
          printf '[dry-run] curl -fsSL -o %q https://github.com/%s/archive/refs/tags/%s.tar.gz\n' "$artifact" "$repo" "$ref"
          printf '[dry-run] extract %q into %q\n' "$artifact" "$extracted"
          printf '[dry-run] install opt tree %q into %q and symlink bins %q into %q\n' "$opt" "$opt_root" "$bins_csv" "$bin_dir"
          ;;
        *)
          die "unsupported install strategy in dry-run: $strategy"
          ;;
      esac
      continue
    fi

    tmp="$(mktemp -d "${cache_root}/.tmp.${name}.XXXXXX")"
    extracted="$tmp/extract"

    case "$strategy" in
      bin|opt)
        if [[ -n "$ref" ]]; then
          info "downloading $name release from $repo tag $ref matching $pkg"
        else
          info "downloading latest $name release from $repo matching $pkg"
          release_pattern_matches_latest "$repo" "$pkg"
        fi
        download_release_artifact "$repo" "$ref" "$pkg" "$tmp"
        artifact="$(find_one_artifact "$tmp")"
        ;;
      source)
        info "downloading $name source archive from $repo tag $ref"
        artifact="$tmp/$name.tar.gz"
        download_source_archive "$repo" "$ref" "$artifact"
        ;;
      *)
        die "unsupported install strategy: $strategy"
        ;;
    esac

    extract_artifact "$artifact" "$extracted"

    case "$strategy" in
      bin)
        install_selected_bins "$extracted" "$bin_dir" "$bins_csv"
        ;;
      opt)
        install_opt_tree_and_links "$extracted" "$opt_root" "$opt" "$bin_dir" "$bins_csv"
        ;;
      source)
        install_opt_tree_and_links "$(source_tree_root "$extracted")" "$opt_root" "$opt" "$bin_dir" "$bins_csv"
        ;;
    esac
  done
}

install_userland_tools "$BOOTSTRAP_PKG_DIR/artifacts.json"

bootstrap_require_ruby() {
  local min="${1:-3.2}"

  command -v ruby >/dev/null 2>&1 || {
    printf 'missing required command: ruby\n' >&2
    return 1
  }

  command -v gem >/dev/null 2>&1 || {
    printf 'missing required command: gem\n' >&2
    return 1
  }

  ruby -rrubygems -e '
required = Gem::Version.new(ARGV[0])
current = Gem::Version.new(RUBY_VERSION)
exit(current >= required ? 0 : 1)
' "$min" || {
    printf 'ruby >= %s required, found %s\n' "$min" "$(ruby -v)" >&2
    return 1
  }
}

bootstrap_install_ruby_gem() {
  local name="$1"
  local version="$2"
  local executable="$3"
  local min_ruby="$4"

  local cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
  local state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  local bin_dir="${USERLAND_BIN:-$HOME/.local/bin}"
  local opt_root="${USERLAND_OPT_HOME:-$HOME/.local/opt}"
  local cache_root="${USERLAND_ARTIFACT_CACHE:-$cache_home/userland/artifacts}"
  local receipt="${USERLAND_RECEIPT:-$state_home/userland/installed.tsv}"
  local tool_path_home="${TOOL_PATH_HOME:-$HOME/.local/share/path}"
  local root gem_home gem_bindir cache_dir wrapper

  root="$opt_root/ruby-gems/$name/$version"
  gem_home="$root/gems"
  gem_bindir="$root/bin"
  cache_dir="$cache_root/ruby-gems/$name/$version"
  wrapper="$tool_path_home/$executable"

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] install ruby gem %s %s\n' "$name" "$version"
    printf '[dry-run] mkdir -p %q %q %q %q\n' "$gem_home" "$gem_bindir" "$cache_dir" "$tool_path_home"
    printf '[dry-run] gem install %q --version %q --install-dir %q --bindir %q --no-document\n' "$name" "$version" "$gem_home" "$gem_bindir"
    printf '[dry-run] install wrapper %q -> %q\n' "$wrapper" "$gem_bindir/$executable"
    return 0
  fi

  bootstrap_require_ruby "$min_ruby"

  if [[ -x "$wrapper" ]] && "$wrapper" --version 2>/dev/null | grep -q "$version"; then
    return 0
  fi

  ensure_dir "$gem_home"
  ensure_dir "$gem_bindir"
  ensure_dir "$cache_dir"
  ensure_dir "$tool_path_home"

  env \
    GEM_HOME="$gem_home" \
    GEM_PATH="$gem_home" \
    GEM_SPEC_CACHE="$cache_dir/specs" \
    gem install "$name" \
      --version "$version" \
      --install-dir "$gem_home" \
      --bindir "$gem_bindir" \
      --no-document

  cat > "$wrapper" <<EOF
#!/usr/bin/env bash
set -euo pipefail
export GEM_HOME='$gem_home'
export GEM_PATH='$gem_home'
export GEM_SPEC_CACHE='$cache_dir/specs'
exec '$gem_bindir/$executable' "\$@"
EOF

  chmod 0755 "$wrapper"

  "$wrapper" --version | grep -q "$version"

  mkdir -p "$(dirname -- "$receipt")"
  printf 'ruby-gem\t%s\t%s\t%s\n' "$name" "$version" "$wrapper" >> "$receipt"
}

bootstrap_install_ruby_gems_manifest() {
  local manifest="$BOOTSTRAP_PKG_DIR/ruby-gems.json"
  local spec name version executable ruby_req min_ruby

  [[ -f "$manifest" ]] || return 0

  command -v jq >/dev/null 2>&1 || {
    printf 'missing required command: jq\n' >&2
    return 1
  }

  while IFS= read -r spec; do
    name="$(jq -r '.name' <<<"$spec")"
    version="$(jq -r '.version' <<<"$spec")"
    executable="$(jq -r '.executable' <<<"$spec")"
    ruby_req="$(jq -r '.ruby' <<<"$spec")"
    min_ruby="${ruby_req#>=}"

    bootstrap_install_ruby_gem "$name" "$version" "$executable" "$min_ruby"
  done < <(jq -c '.gems[]' "$manifest")
}

bootstrap_install_ruby_gems_manifest

bootstrap_install_cue() {
  local version="${CUE_VERSION:-v0.16.1}"
  local repo="cue-lang/cue"
  local cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
  local state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  local bin_dir="${USERLAND_BIN:-$HOME/.local/bin}"
  local opt_root="${USERLAND_OPT_HOME:-$HOME/.local/opt}"
  local cache_root="${USERLAND_ARTIFACT_CACHE:-$cache_home/userland/artifacts}"
  local receipt="${USERLAND_RECEIPT:-$state_home/userland/installed.tsv}"
  local tool_path_home="${TOOL_PATH_HOME:-$HOME/.local/share/path}"
  local goos goarch asset
  local cache_dir install_dir tmp archive cue_bin

  command -v gh >/dev/null 2>&1 || {
    printf 'missing required command: gh\n' >&2
    return 1
  }

  command -v jq >/dev/null 2>&1 || {
    printf 'missing required command: jq\n' >&2
    return 1
  }

  command -v tar >/dev/null 2>&1 || {
    printf 'missing required command: tar\n' >&2
    return 1
  }

  case "$(uname -s)" in
    Linux) goos="linux" ;;
    Darwin) goos="darwin" ;;
    *)
      printf 'unsupported OS for cue install: %s\n' "$(uname -s)" >&2
      return 1
      ;;
  esac

  case "$(uname -m)" in
    x86_64|amd64) goarch="amd64" ;;
    aarch64|arm64) goarch="arm64" ;;
    *)
      printf 'unsupported arch for cue install: %s\n' "$(uname -m)" >&2
      return 1
      ;;
  esac

  asset="cue_${version}_${goos}_${goarch}.tar.gz"
  cache_dir="$cache_root/cue/$version"
  install_dir="$opt_root/cue/$version"
  tmp="$cache_dir/extract"
  archive="$cache_dir/$asset"

  if [[ -x "$install_dir/bin/cue" ]] &&
     "$install_dir/bin/cue" version 2>/dev/null | grep -q "cue version $version"
  then
    ln -sfn -- "$install_dir/bin/cue" "$tool_path_home/cue"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] install cue %s asset=%s\n' "$version" "$asset"
    printf '[dry-run] mkdir -p %q %q %q\n' "$cache_dir" "$install_dir/bin" "$tool_path_home"
    printf '[dry-run] gh release download -R %q --pattern %q --dir %q --clobber\n' "$repo" "$asset" "$cache_dir"
    printf '[dry-run] tar -xzf %q -C %q\n' "$archive" "$tmp"
    printf '[dry-run] install -m 0755 <extracted cue> %q\n' "$install_dir/bin/cue"
    printf '[dry-run] ln -sfn %q %q\n' "$install_dir/bin/cue" "$tool_path_home/cue"
    return 0
  fi

  ensure_dir "$cache_dir"
  ensure_dir "$install_dir/bin"
  ensure_dir "$tool_path_home"
  rm -rf -- "$tmp"
  mkdir -p -- "$tmp"

  gh release download "$version" \
    --repo "$repo" \
    --pattern "$asset" \
    --dir "$cache_dir" \
    --clobber

  if [[ ! -f "$archive" ]]; then
    if [[ -f "$cache_dir/$asset" ]]; then
      mv -- "$cache_dir/$asset" "$archive"
    else
      printf 'cue archive not found after download: %s\n' "$archive" >&2
      return 1
    fi
  fi

  tar -xzf "$archive" -C "$tmp"

  cue_bin="$(
    find "$tmp" -type f -name cue -perm -u+x |
      head -n 1
  )"

  if [[ -z "$cue_bin" ]]; then
    printf 'cue binary not found after extraction\n' >&2
    return 1
  fi

  install -m 0755 -- "$cue_bin" "$install_dir/bin/cue"
  ln -sfn -- "$install_dir/bin/cue" "$tool_path_home/cue"

  "$tool_path_home/cue" version | grep -q "cue version $version"

  mkdir -p "$(dirname -- "$receipt")"
  printf 'cue\t%s\t%s\t%s\n' "$version" "$install_dir/bin/cue" "$asset" >> "$receipt"
}

bootstrap_install_cue
