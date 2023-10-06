<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Available versions

The versions of jq, yq, gojq, xq and jaq can be specified by version number or `"none"` or `"latest"` as follows.

Note that for the `linux/arm64` platform, **the `jqVersion` option only supports jq version 1.7rc1 or later**.

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

To install RC versions of jq, another option `"allowJqRcVersion"` must be set to `true`.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:1": {
        "jqVersion": "1.7rc1",
        "allowJqRcVersion": true
    }
}
```

If `"jqVersion": "os-provided"` is specified, jq will be installed via the package manager.

## Release notes

### 2.0.0

- Change the default value of `jqVersion` from `"os-provided"` to `"latest"`.

## References

- jq: <https://jqlang.github.io/jq>
- yq: <https://mikefarah.gitbook.io/yq>
- gojq: <https://github.com/itchyny/gojq>
- xq: <https://github.com/MiSawa/xq>
- jaq: <https://github.com/01mf02/jaq>
