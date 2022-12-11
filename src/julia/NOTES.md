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
