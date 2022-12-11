
# Julia (julia)

Installs Julia

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/julia:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select version of Julia. | string | latest |
| installNonStable | If ture, the non-stable versions are a candidate for installation. For example, the latest might be the latest RC version. | boolean | false |

<!-- markdownlint-disable MD041 -->

## Available versions

If you want to install the non-stable versions, the `installNonStable` option must be set to `true`.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/julia:0": {
        "version": "1.9.0-alpha1",
        "installNonStable": true
    }
}
```

If the `installNonStable` option is not explicitly set to `true`, only the stable versions will be installed.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/julia:0": {
        "version": "1"
    }
}
```

## References

- julia: <https://julialang.org>


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/julia/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
