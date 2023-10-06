
# jq, yq, gojq, xq, jaq (jq-likes)

Installs jq and jq like command line tools (yq, gojq, xq, jaq).

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:2": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| jqVersion | Select version of jq. | string | latest |
| yqVersion | Select version of yq. | string | none |
| gojqVersion | Select version of gojq. | string | none |
| xqVersion | Select version of xq. | string | none |
| jaqVersion | Select version of jaq. | string | none |
| allowJqRcVersion | Allow jq pre-release RC version to be installed. | boolean | false |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/jq-likes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
