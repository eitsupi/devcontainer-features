
# jj (Jujutsu) (jujutsu-cli)

Installs jj (Jujutsu), a Git-compatible version control system.

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jujutsu-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select version of jj. | string | latest |
| completionMode | Select shell completion mode for bash/zsh/fish. 'dynamic' is recommended by jj docs. | string | dynamic |
| configureUserFromGit | If true, read git global user.name/user.email and set jj user.name/user.email (skips if jj user config already exists). | boolean | true |

<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Notes

This feature enables shell completion automatically for bash/zsh/fish.

By default it installs **dynamic completions** (as recommended in jj docs). Set `completionMode` to `standard` if you prefer static completions, or `none` to disable.

If `configureUserFromGit` is enabled (default), it will run on `postStartCommand` and read `git config --global user.name/user.email`, then set `jj config set --user user.name/user.email` (skips if `${HOME}/.config/jj/` already exists).

## References

- jj docs: <https://docs.jj-vcs.dev/>
- jj (Jujutsu): <https://github.com/jj-vcs/jj>


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/jujutsu-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
