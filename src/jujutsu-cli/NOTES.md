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
