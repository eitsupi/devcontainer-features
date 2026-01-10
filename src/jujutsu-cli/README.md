
# Jujutsu CLI (jj) (jujutsu-cli)

Installs Jujutsu CLI (jj), a Git-compatible version control system.

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jujutsu-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select version of Jujutsu CLI (jj). | string | latest |
| completionMode | Select shell completion mode for bash/zsh/fish. 'dynamic' is recommended by jj docs. | string | dynamic |

<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Notes

This feature enables shell completion automatically for bash/zsh/fish.

By default it installs **dynamic completions** (as recommended in jj docs). Set `completionMode` to `standard` if you prefer static completions, or `none` to disable.

## References

- Jujutsu (jj): <https://github.com/jj-vcs/jj>


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/jujutsu-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
