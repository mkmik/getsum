// Package modfetch knows how to fetch and verify Go modules.
package modfetch

import (
	"fmt"
	"io"
	"io/ioutil"
	"net/http"

	"golang.org/x/mod/sumdb/dirhash"
)

const (
	DefaultProxyURL = "https://proxy.golang.org"
)

var (
	ProxyURL = DefaultProxyURL

	client = &http.Client{}
)

func init() {
	t := &http.Transport{}
	t.RegisterProtocol("file", http.NewFileTransport(http.Dir("/")))
	client.Transport = t
}

// DownloadModuleZip downloads a Go module zip file and verifies it against the SumDB.
func DownloadModuleZip(modulePath, version string) (string, error) {
	w, err := ioutil.TempFile("", "*.zip")
	if err != nil {
		return "", nil
	}
	defer w.Close()

	u := fmt.Sprintf("%s/%s/@v/%s.zip", ProxyURL, modulePath, version)
	resp, err := client.Get(u)
	if err != nil {
		return "", nil
	}
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("got bad status %q while fetching: %s", resp.Status, u)
	}
	defer resp.Body.Close()

	if _, err := io.Copy(w, resp.Body); err != nil {
		return "", nil
	}
	w.Close()

	if err := verifyModuleZip(w.Name(), modulePath, version); err != nil {
		return "", nil
	}
	return w.Name(), nil
}

// verifyModule verifies a module zip against the SumDB.
func verifyModuleZip(zipFilename, modulePath, version string) error {
	local, err := dirhash.HashZip(zipFilename, dirhash.DefaultHash)
	if err != nil {
		return err
	}

	remote, err := FetchSumDB(modulePath, version)
	if err != nil {
		return err
	}

	if local != remote {
		return fmt.Errorf("the oracle %q has been tampered with (%q != %q)", modulePath, local, remote)
	}
	return nil
}
