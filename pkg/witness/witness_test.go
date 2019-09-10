package witness

import (
	"strings"
	"testing"
)

func TestEncodeURLToModulePath(t *testing.T) {
	testCases := []struct {
		url string
		enc string
		err string
	}{
		{
			url: "https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.8.3/kubeseal-darwin-amd64",
			enc: "getsum.pub/https/github.com/2riLzdMNGVoqSNSjL/jRZemZEK13AQcxMKrSv/L8nc6eyCPri/HoMGCnPUSbu/21rYnBBbQ/7cFcbfzURYBhwQZ2xT8bqaVa9d1zB",
		},
		{
			url: "http://foobar.com/a/b",
			enc: "getsum.pub/http/foobar.com/2g/2h",
		},
		{
			url: "https://github.com",
			err: "directories not supported",
		},
	}

	for _, tc := range testCases {
		if m, err := EncodeURLToModulePath(tc.url); err != nil {
			if tc.err == "" || !strings.Contains(err.Error(), tc.err) {
				t.Error(err)
			}
		} else if got, want := m, tc.enc; got != want {
			t.Errorf("got: %q, want: %q", got, want)
		}
	}
}

func TestDecodeURLToModulePath(t *testing.T) {
	testCases := []string{
		"https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.8.3/kubeseal-darwin-amd64",
		"http://foobar.com/a/b",
	}

	for _, tc := range testCases {
		t.Run(tc, func(t *testing.T) {
			m, err := EncodeURLToModulePath(tc)
			if err != nil {
				t.Fatal(err)
			}

			got, err := DecodeURLFromModulePath(m)
			if err != nil {
				t.Fatal(err)
			}
			if want := tc; got != want {
				t.Errorf("got: %q, want: %q", got, want)
			}
		})
	}
}
