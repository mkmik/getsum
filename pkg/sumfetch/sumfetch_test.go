package sumfetch

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestFetchSumFile(t *testing.T) {
	const (
		testFile = "test1"
		testHash = "d646175769c0c536e6ad6fd6987d096c559b6bf2aaf56d44591466065a6b4b70"
	)

	handler := func(p string) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			if r.URL.Path == "/"+p {
				fmt.Fprintf(w, testHash+"  "+testFile)
				return
			}
			http.NotFound(w, r)
		}
	}

	testCases := []string{testFile + ".sha256", "SHA256SUM"}

	for _, tc := range testCases {
		t.Run(tc, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(handler(tc)))
			defer server.Close()

			sf, err := FetchSumFile(fmt.Sprintf("%s/%s", server.URL, testFile))
			if err != nil {
				t.Fatal(err)
			}

			if got, want := len(sf), 1; got != want {
				t.Errorf("got: %d, want: %d", got, want)
			}
			if got, want := sf[testFile], testHash; got != want {
				t.Errorf("got: %q, want: %q", got, want)
			}
		})
	}
}
