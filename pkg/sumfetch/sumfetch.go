// Package sumfetch knows how to obtain the official checksum file for a given URL.
package sumfetch

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"path"

	"getsum.pub/getsum/pkg/sumfile"
)

// FetchSumFile knows how to obtain the official checksum file for a given URL.
func FetchSumFile(u string) (sumfile.SumFile, error) {
	r, err := openSumFile(u)
	if err != nil {
		return nil, err
	}
	defer r.Close()
	return sumfile.Parse(r)
}

func openSumFile(u string) (io.ReadCloser, error) {
	pu, err := url.Parse(u)
	if err != nil {
		return nil, err
	}

	single := *pu
	single.Path = fmt.Sprintf("%s.sha256", single.Path)
	resp, err := http.Get(single.String())
	if err != nil {
		return nil, err
	}

	if resp.StatusCode == http.StatusOK {
		return resp.Body, nil
	}

	multi := *pu
	multi.Path = path.Join(path.Dir(multi.Path), "SHA256SUMS")
	resp, err = http.Get(multi.String())
	if err != nil {
		return nil, err
	}

	if resp.StatusCode == http.StatusOK {
		return resp.Body, nil
	}

	return nil, fmt.Errorf("cannot find signature for %q", u)
}
