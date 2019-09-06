## Install

```bash
$ GO111MODULE=on go get getsum.pub/getsum@v0.0.5
```

## Usage

```bash
$ getsum https://some.com/url/to/a/file
```

`getsum` returns the hash of a file. The hash is fetched by `getsum.pub` by reading `https://some.com/url/to/a/file.sha256` and falling back to `https://some.com/url/to/a/SHA256SUM` (we'll add more ways to seeding the hash; although we're likeley keep avoiding downloading large files from the internet)

However, `getsum.pub` doesn't directly serve the hash to the `getsum.pub` client.
Instead it generates a fake Go module `getsum.pub/https/some.com/ovzgy/orxq/me/mzuwyzi` (all path components are base32-encoded to ensure any URL is a valid Go import path)
which contains the original URL and the sha256 checksum of it.

The `getsum` client then fetches this module using the https://proxy.golang.org and verifies the checksum using https://sum.golang.org. (read more about it [here](https://go.googlesource.com/proposal/+/master/design/25530-sumdb.md))

Thus we neverage an existing large scale transparent log to ensure that files are indeed **immutable** the original publisher of that URL never changes the file (and the published `.sha` file).

