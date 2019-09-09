package sumfile

import (
	"fmt"
	"strings"
	"testing"
)

func TestHashForUrl(t *testing.T) {
	const (
		testFile = "test1"
		testHash = "d646175769c0c536e6ad6fd6987d096c559b6bf2aaf56d44591466065a6b4b70"
	)

	sf := SumFile{testFile: testHash}
	h, err := sf.HashForURL("http://localhost:8080/foo/bar/test1?auth-token=123")
	if err != nil {
		t.Fatal(err)
	}
	if got, want := h, testHash; got != want {
		t.Errorf("got: %q, want: %q", got, want)
	}
}

func TestParse(t *testing.T) {
	r := strings.NewReader(`17ff527e79ad64071f55df615836772f1164eedc7c073ce4de05d1f251683f08  sumfile.go
86da0f39b67cc0044244b70b6398d5f9ffe96db9159533b9e13ed378d68991b4  sumfile_test.go`)

	sf, err := Parse(r)
	if err != nil {
		t.Fatal(err)
	}

	if got, want := len(sf), 2; got != want {
		t.Errorf("got: %v, want: %v", got, want)
	}

	if got, want := sf["sumfile.go"], "17ff527e79ad64071f55df615836772f1164eedc7c073ce4de05d1f251683f08"; got != want {
		t.Errorf("got: %v, want: %v", got, want)
	}
}

func TestSplitLine(t *testing.T) {
	testCases := []struct {
		line string
		ok   bool
	}{
		{"af273620cea97d9aec6e09f4fb847c020b0bb95eee07c8eb5562027adfcc936c  getsum", true},
		{"af273620cea97d9aec6e09f4fb847c020b0bb95eee07c8eb5562027adfcc936c *getsum", true},
		{"af273620cea97d9aec6e09f4fb847c020b0bb95eee07c8eb5562027adfcc936c getsum", false},
	}

	const (
		wantHash = "af273620cea97d9aec6e09f4fb847c020b0bb95eee07c8eb5562027adfcc936c"
		wantFile = "getsum"
	)

	for i, tc := range testCases {
		t.Run(fmt.Sprint(i), func(t *testing.T) {
			h, f, err := splitLine(tc.line)
			if (err == nil) != tc.ok {
				t.Fatalf("expecting success: %v, got error: %v", tc.ok, err)
			}
			if tc.ok {
				if got, want := h, wantHash; got != want {
					t.Errorf("got: %q, want: %q", got, want)
				}
				if got, want := f, wantFile; got != want {
					t.Errorf("got: %q, want: %q", got, want)
				}
			}
		})
	}
}
