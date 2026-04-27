"$HOME/.config/shell/validate-env.sh"

bash -n "$HOME/.config/yadm/bootstrap"
for f in "$HOME"/.config/yadm/bootstrap.d/*.sh; do
  bash -n "$f"
done

DRY_RUN=1 HOST_CLASS="${HOST_CLASS:-debian-base}" "$HOME/.config/yadm/bootstrap"

"$HOME/.config/dotfiles-audit/audit.sh" \
  .config/bin \
  .config/broot \
  .config/nvim \
  .config/uv

yadm status --short --branch
