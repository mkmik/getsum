package modfetch

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"

	"golang.org/x/mod/sumdb"
)

var (
	vkey  = flag.String("k", "sum.golang.org+033de0ae+Ac4zctda0e5eza+HJyk9SxEdh+s3Ux18htTTAD8OuAn8", "key")
	vflag = flag.Bool("v", false, "enable verbose output")

	hashRegex = regexp.MustCompile(`h1:(.*)`)
)

// FetchSumDB fetches the hash of the file tree
func FetchSumDB(modulePath, version string) (string, error) {
	client := sumdb.NewClient(new(clientOps))

	lines, err := client.Lookup(modulePath, version)
	if err != nil {
		return "", err
	}
	line := lines[0]

	h := hashRegex.FindString(line)
	if h == "" {
		return "", fmt.Errorf("cannot parse mod hash line %q", line)
	}
	return h, nil
}

// clientOps is a dummy implementation that doesn't preserve the cache and thus doesn't fully partecipate
// in the transparency log verification.
// See https://github.com/golang/go/blob/master/src/cmd/go/internal/modfetch/sumdb.go for a fuller implementation
type clientOps struct{}

func (*clientOps) ReadConfig(file string) ([]byte, error) {
	if file == "key" {
		return []byte(*vkey), nil
	}
	if strings.HasSuffix(file, "/latest") {
		// Looking for cached latest tree head.
		// Empty result means empty tree.
		return []byte{}, nil
	}
	return nil, fmt.Errorf("unknown config %s", file)
}

func (*clientOps) WriteConfig(file string, old, new []byte) error {
	// Ignore writes.
	return nil
}

func (*clientOps) ReadCache(file string) ([]byte, error) {
	return nil, fmt.Errorf("no cache")
}

func (*clientOps) WriteCache(file string, data []byte) {
	// Ignore writes.
}

func (*clientOps) Log(msg string) {
	log.Print(msg)
}

func (*clientOps) SecurityError(msg string) {
	log.Fatal(msg)
}

func init() {
	http.DefaultClient.Timeout = 1 * time.Minute
}

func (*clientOps) ReadRemote(path string) ([]byte, error) {
	name := *vkey
	if i := strings.Index(name, "+"); i >= 0 {
		name = name[:i]
	}
	start := time.Now()
	target := "https://" + name + path
	/*
		if *url != "" {
			target = *url + path
		}
	*/
	resp, err := http.Get(target)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("GET %v: %v", target, resp.Status)
	}
	data, err := ioutil.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return nil, err
	}
	if *vflag {
		fmt.Fprintf(os.Stderr, "%.3fs %s\n", time.Since(start).Seconds(), target)
	}
	return data, nil
}
