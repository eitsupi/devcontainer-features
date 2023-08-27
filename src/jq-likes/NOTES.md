<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Available versions

The versions of yq, gojq and xq can be specified by version number or `"latest"` as follows.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:1": {
        "jqVersion": "none",
        "yqVersion": "4",
        "gojqVersion": "latest",
        "xqVersion": "latest"
    }
}
```

Also specify the version of jq to be installed with `"jqVersion"`. But **this option only supports jq version 1.7rc1 or later**,
and for to install RC versions, another option `"allowJqRcVersion"` must be set to `true`.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:1": {
        "jqVersion": "1.7rc1",
        "allowJqRcVersion": true
    }
}
```

If `"jqVersion": "os-provided"` is specified (default), jq will be installed via the package manager.

## References

- jq: <https://jqlang.github.io/jq>
- yq: <https://mikefarah.gitbook.io/yq>
- gojq: <https://github.com/itchyny/gojq>
- xq: <https://github.com/MiSawa/xq>
