#!/usr/bin/env bash

artifact_rows() {
  local manifest=${1:?manifest}
  jq -r '
    .artifacts[]
    | select((.enabled // true) == true)
    | [
        .name,
        .repo,
        .pkg,
        (.install // "bin"),
        (.opt // .name),
        (.bins | join(","))
      ]
    | @tsv
  ' "$manifest"
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
  local row name repo pkg strategy opt bins_csv first_bin tmp artifact extracted
  mapfile -t rows < <(artifact_rows "$manifest")

  for row in "${rows[@]}"; do
    [[ -n "$row" ]] || continue
    IFS=$'\t' read -r name repo pkg strategy opt bins_csv <<< "$row"

    [[ -n "$name" && -n "$repo" && -n "$pkg" && -n "$strategy" && -n "$bins_csv" ]] \
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
      info "would install $name from latest $repo matching $pkg"
      printf '[dry-run] jq -r %q %q\n' '.artifacts[] | select((.enabled // true) == true) | [.name,.repo,.pkg,(.install // "bin"),(.opt // .name),(.bins | join(","))] | @tsv' "$manifest"
      printf '[dry-run] gh release download -R %q --pattern %q --dir %q\n' "$repo" "$pkg" "$tmp"
      printf '[dry-run] extract %q into %q\n' "$artifact" "$extracted"
      case "$strategy" in
        bin)
          printf '[dry-run] install bins %q into %q\n' "$bins_csv" "$bin_dir"
          ;;
        opt)
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

    info "downloading latest $name from $repo matching $pkg"
    release_pattern_matches_latest "$repo" "$pkg"
    gh release download -R "$repo" --pattern "$pkg" --dir "$tmp"

    artifact="$(find_one_artifact "$tmp")"
    extract_artifact "$artifact" "$extracted"

    case "$strategy" in
      bin)
        install_selected_bins "$extracted" "$bin_dir" "$bins_csv"
        ;;
      opt)
        install_opt_tree_and_links "$extracted" "$opt_root" "$opt" "$bin_dir" "$bins_csv"
        ;;
      *)
        die "unsupported install strategy: $strategy"
        ;;
    esac
  done
}

install_userland_tools "$BOOTSTRAP_PKG_DIR/artifacts.json"
