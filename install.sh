#!/usr/bin/env bash
set -euo pipefail

# Run only inside GitHub Codespaces.
if [[ "${CODESPACES:-}" != "true" ]]; then
  exit 0
fi

dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install personal Bash settings.
mkdir -p "$HOME/.config/codespaces"

cp "$dotfiles_dir/codespaces.bash" \
  "$HOME/.config/codespaces/personal.bash"

startup_line='source "$HOME/.config/codespaces/personal.bash"'

touch "$HOME/.bashrc"

if ! grep -qxF "$startup_line" "$HOME/.bashrc"; then
  printf '\n%s\n' "$startup_line" >> "$HOME/.bashrc"
fi

# Make Poetry accessible during installation.
export PATH="$HOME/.local/bin:$PATH"

# Install Git LFS if missing.
if ! git lfs version >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y git-lfs
fi

git lfs install --skip-repo

# Keep Poetry separate from project dependencies.
python3 -m venv "$HOME/.local/share/jans-docs-poetry"

"$HOME/.local/share/jans-docs-poetry/bin/python" \
  -m pip install poetry

mkdir -p "$HOME/.local/bin"

ln -sfn \
  "$HOME/.local/share/jans-docs-poetry/bin/poetry" \
  "$HOME/.local/bin/poetry"

# Install dependencies for Zensical documentation projects.
for project_file in /workspaces/*/docs/pyproject.toml; do
  [[ -f "$project_file" ]] || continue
  grep -qi 'zensical' "$project_file" || continue

  docs_dir="$(dirname "$project_file")"

  echo "Installing documentation dependencies in $docs_dir"

  (
    cd "$docs_dir"
    poetry install --no-root
    poetry run zensical --version
  )
done

echo "Personal Codespaces setup finished."