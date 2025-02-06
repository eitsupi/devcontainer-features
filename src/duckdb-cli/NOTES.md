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
