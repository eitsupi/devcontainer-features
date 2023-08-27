
# jq, yq, gojq, xq (jq-likes)

Installs jq and jq like command line tools (yq, gojq, xq).

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| jqVersion | Select version of jq. | string | os-provided |
| yqVersion | Select version of yq. | string | none |
| gojqVersion | Select version of gojq. | string | none |
| xqVersion | Select version of xq. | string | none |
| allowJqRcVersion | Allow jq pre-release RC version to be installed. | boolean | false |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/jq-likes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
