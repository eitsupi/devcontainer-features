<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Notes

This feature enables shell completion automatically for bash/zsh/fish.

By default it installs dynamic completions (as recommended in jj docs). Set `completionMode` to `standard` or `none` if needed.

If `configureUserFromGit` is enabled (default), it will run on `postStartCommand` and copy `git config --global user.name/user.email` into `jj` user config (skips if `${HOME}/.config/jj/` already exists).

## References

- jj (Jujutsu): <https://github.com/jj-vcs/jj>
