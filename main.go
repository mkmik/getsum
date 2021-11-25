package main

import (
	"crypto/sha256"
	"encoding/hex"
	"flag"
	"fmt"
	"io"
	"log"
	"os"

	"getsum.pub/getsum/pkg/manifest"
	"getsum.pub/getsum/pkg/modfetch"
	"getsum.pub/getsum/pkg/sumfetch"
	"getsum.pub/getsum/pkg/witness"
)

var (
	witnessModPath = flag.String("witness", "", "override Go module (repo) of the witness")
	dryRun         = flag.Bool("dry-run", false, "Do not actually pollute SumDB")
	check          = flag.String("c", "", "Check whether an already downloaded file matches the checksum")
)

func usage() {
	fmt.Fprintf(os.Stderr, "usage: getsum ....\n")
	flag.PrintDefaults()
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

	if *check != "" {
		fh := sha256.New()
		f, err := os.Open(*check)
		if err != nil {
			return err
		}
		defer f.Close()
		io.Copy(fh, f)

		h2 := hex.EncodeToString(fh.Sum(nil))
		if h != h2 {
			fmt.Fprintf(os.Stderr, "checksum mismatch: %q -> %q, transparency log -> %q", h2, h, artifactURL)
		}
	} else {
		fmt.Println(h)
	}

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
