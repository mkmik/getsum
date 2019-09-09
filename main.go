package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"getsum.pub/getsum/pkg/manifest"
	"getsum.pub/getsum/pkg/modfetch"
	"getsum.pub/getsum/pkg/witness"
	"getsum.pub/getsum/pkg/sumfetch"
)

var (
	witnessModPath = flag.String("witness", "", "override Go module (repo) of the witness")
	dryRun        = flag.Bool("dry-run", false, "Do not actually pollute SumDB")
)

func usage() {
	fmt.Fprintf(os.Stderr, "usage: getsum ....\n")
	os.Exit(2)
}

func run(artifactURL string, witnessModPath string) error {
	// let's first ensure that the URL we're about to download is supported by getsum.pub
	sf, err := sumfetch.FetchSumFile(artifactURL)
	if err != nil {
		return err
	}
	_, err = sf.HashForURL(artifactURL)
	if err != nil {
		return err
	}

	// now let's download the "witness"
	if witnessModPath == "" {
		var err error
		witnessModPath, err = witness.EncodeURLToModulePath(artifactURL)
		if err != nil {
			return err
		}
	}

	witnessZip, err := modfetch.DownloadModuleZip(witnessModPath, manifest.CanonicalVersion)
	if err != nil {
		return err
	}
	defer os.RemoveAll(witnessZip)

	o, err := witness.ParseFromZip(witnessZip)
	if err != nil {
		return err
	}

	// and print the hash for the witness. We could use this hash to verify the download.
	h, err := o.Hash(artifactURL)
	if err != nil {
		return err
	}

	fmt.Println(h)
	return nil
}

func main() {
	flag.Usage = usage
	flag.Parse()

	if flag.NArg() != 1 {
		usage()
	}

	if p, ok := os.LookupEnv("GOPROXY"); ok {
		modfetch.ProxyURL = p
	}
	modfetch.DryRun = *dryRun

	if err := run(flag.Arg(0), *witnessModPath); err != nil {
		log.Fatal(err)
	}
}
