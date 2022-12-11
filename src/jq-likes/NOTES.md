<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Available versions

The versions of yq and gojq can be specified by version number or `"latest"` as follows.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:1": {
        "jqVersion": "none",
        "yqVersion": "4",
        "gojqVersion": "latest"
    }
}
```

## References

- jq: <https://stedolan.github.io/jq>
- yq: <https://mikefarah.gitbook.io/yq>
- gojq: <https://github.com/itchyny/gojq>
