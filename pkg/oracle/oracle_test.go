package oracle

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
			enc: "github.com/mjuxi3tbnvus23dbmjzq/onswc3dfmqwxgzldojsxi4y/ojswyzlbonsxg/mrxxo3tmn5qwi/oyyc4obogm/nn2wezltmvqwyllemfzho2lofvqw2zbwgq",
		},
		{
			url: "https://github.com",
			enc: "github.com/",
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