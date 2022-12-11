
# jq, yq, gojq (jq-likes)

Installs jq and jq like command line tools (yq, gojq).

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

<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## Available versions

The versions of yq and gojq can be specified by version number or `"latest"` as follows.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/jq-likes:0": {
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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/jq-likes/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
