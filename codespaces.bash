# Make Poetry accessible in every Bash terminal.
export PATH="$HOME/.local/bin:$PATH"

# Use Git configuration for the committer identity.
if [[ "${CODESPACES:-}" == "true" ]]; then
  unset GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
fi