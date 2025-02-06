
# DuckDB CLI (duckdb-cli)

DuckDB is an in-process SQL OLAP database management system.

## Example Usage

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/duckdb-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select version of DuckDB CLI. | string | latest |
| extensions | Comma separated list of DuckDB extensions to install. | string | - |
| communityExtensions | Comma separated list of DuckDB Community Extensions to install. | string | - |

<!-- markdownlint-disable MD041 -->

## Supported platforms

`linux/amd64` and `linux/arm64` platforms `debian` and `ubuntu`.

## How to specify extensions?

Specify extension names separated by commas in the `extensions` option.

The following example installs `httpfs` and `sqlite_scanner`.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/duckdb-cli:1": {
        "extensions": "httpfs,sqlite_scanner"
    }
}
```

Similarly, we can install [DuckDB Community Extensions](https://duckdb.org/community_extensions/)
by specifying the `communityExtensions` option.

```json
"features": {
    "ghcr.io/eitsupi/devcontainer-features/duckdb-cli:1": {
        "communityExtensions": "quack"
    }
}
```

## References

- DuckDB: <https://duckdb.org>
- DuckDB CLI API: <https://duckdb.org/docs/api/cli>
- DuckDB Extensions: <https://duckdb.org/docs/extensions/overview>


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/eitsupi/devcontainer-features/blob/main/src/duckdb-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
