### **IMPORTANT NOTE**
- **This Feature is deprecated, and will no longer receive any further updates/support.**

# Julia (julia)

Installs specific version of Julia.

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
| allowNonStableVersion | If ture, the non-stable versions are candidates for installation. For example, the latest might be the latest alpha, beta, or RC version. | boolean | false |

## Customizations

### VS Code Extensions

- `julialang.language-julia`

<!-- markdownlint-disable MD041 -->

## Note about deprecation

This Feature was deprecated in favor of
[`ghcr.io/julialang/devcontainer-features/julia`](https://github.com/JuliaLang/devcontainer-features/tree/main/src/julia).

## Available versions

If you want to install the non-stable versions, the `allowNonStableVersion` option must be set to `true`.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/julia:0": {
        "version": "1.9.0-alpha1",
        "allowNonStableVersion": true
    }
}
```

If the `allowNonStableVersion` option is not explicitly set to `true`, only the stable versions will be installed.

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
