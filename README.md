# Public Artifact Checksums Witness

This server observes and records checksums of publicly downloadable artifacts.
It offers verifiable proof that the claimed observations are immutable, i.e. this server cannot serve a different claim in the future.

It can be used to detect URLs whose content breaks immutability guarantees (e.g. usually versioned software releases).

## Install

```bash
$ GO111MODULE=on go get getsum.pub/getsum@latest
```

## Usage

```bash
$ getsum https://some.com/url/to/a/file
```

`getsum` returns the hash of a file. The hash is fetched by `getsum.pub` by reading `https://some.com/url/to/a/file.sha256` and falling back to `https://some.com/url/to/a/SHA256SUMS` (we'll add more ways to seeding the hash; although we're likeley keep avoiding downloading large files from the internet)

However, `getsum.pub` doesn't directly serve the hash to the `getsum.pub` client.
Instead it generates a fake Go module `getsum.pub/https/some.com/ovzgy/orxq/me/mzuwyzi` (all path components are base32-encoded to ensure any URL is a valid Go import path)
which contains the original URL and the sha256 checksum of it.

The `getsum` client then fetches this module using the https://proxy.golang.org and verifies the checksum using https://sum.golang.org. (read more about it [here](https://go.googlesource.com/proposal/+/master/design/25530-sumdb.md))

Thus we leverage an existing large scale transparent log to ensure that files are indeed **immutable** the original publisher of that URL never changes the file (and the published `.sha` file).

