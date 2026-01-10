
# Beads CLI (bd) (beads-cli)

Installs Beads CLI (bd), a distributed, git-backed graph issue tracker for AI agents.

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/beads-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select version of Beads CLI (bd). | string | latest |

<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Notes

Shell completion is enabled automatically for:

- bash (appends completion script to `~/.bashrc_profile`)
- zsh (writes `_bd` to `/usr/local/share/zsh/site-functions/` when available)
- fish (writes `bd.fish` to `~/.config/fish/completions/` when available)

## References

- Beads: <https://github.com/steveyegge/beads>


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/beads-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
