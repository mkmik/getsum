package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"

	"golang.org/x/mod/sumdb"
	"golang.org/x/mod/sumdb/dirhash"
)

const (
	fixedVersion = "v0.0.2"
	proxyURL     = "https://proxy.golang.org"
)

var (
	oracleModPath = flag.String("oracle", "", "override Go module (repo) of the oracle")
)

func usage() {
	fmt.Fprintf(os.Stderr, "usage: getsum ....\n")
	os.Exit(2)
}

func run(artifactURL string, oracleModPath string) error {
	oracleZip, err := ioutil.TempFile("", "*.zip")
	if err != nil {
		return err
	}
	defer os.RemoveAll(oracleZip.Name())

	if err := downloadModuleZip(oracleZip, oracleModPath); err != nil {
		return err
	}
	oracleZip.Close()

	if err := verifyModuleZip(oracleZip.Name(), oracleModPath); err != nil {
		return err
	}

	o, err := parseOracle(oracleZip.Name())
	if err != nil {
		return err
	}
	h, err := o.Hash(artifactURL)
	if err != nil {
		return err
	}

	fmt.Println(h)
	return nil
}

func downloadModuleZip(w io.Writer, oracleModPath string) error {
	resp, err := http.Get(fmt.Sprintf("%s/%s/@v/%s.zip", proxyURL, oracleModPath, fixedVersion))
	if err != nil {
		return err
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("got bad status %q", resp.Status)
	}
	defer resp.Body.Close()

	if _, err := io.Copy(w, resp.Body); err != nil {
		return err
	}
	return nil
}

// verifyModule verifies a module zip against the SumDB.
func verifyModuleZip(zipFilename, modulePath string) error {
	local, err := dirhash.HashZip(zipFilename, dirhash.DefaultHash)
	if err != nil {
		return err
	}

	remote, err := fetchSumDB(modulePath)
	if err != nil {
		return err
	}

	if local != remote {
		return fmt.Errorf("the oracle %q has been tampered with (%q != %q)", modulePath, local, remote)
	}
	return nil
}

var hashRegex = regexp.MustCompile(`h1:(.*)`)

func fetchSumDB(modulePath string) (string, error) {
	client := sumdb.NewClient(new(clientOps))

	lines, err := client.Lookup(modulePath, fixedVersion)
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

func main() {
	flag.Usage = usage
	flag.Parse()

	if flag.NArg() != 1 {
		usage()
	}

	if err := run(flag.Arg(0), *oracleModPath); err != nil {
		log.Fatal(err)
	}
}
