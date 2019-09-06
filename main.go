package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"getsum.pub/getsum/pkg/getsum"
	"getsum.pub/getsum/pkg/modfetch"
	"getsum.pub/getsum/pkg/oracle"
)

var (
	oracleModPath = flag.String("oracle", "", "override Go module (repo) of the oracle")
)

func usage() {
	fmt.Fprintf(os.Stderr, "usage: getsum ....\n")
	os.Exit(2)
}

func run(artifactURL string, oracleModPath string) error {
	oracleZip, err := modfetch.DownloadModuleZip(oracleModPath, getsum.CanonicalVersion)
	if err != nil {
		return err
	}
	defer os.RemoveAll(oracleZip)

	o, err := oracle.ParseFromZip(oracleZip)
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

func main() {
	flag.Usage = usage
	flag.Parse()

	if flag.NArg() != 1 {
		usage()
	}

	if p, ok := os.LookupEnv("GOPROXY"); ok {
		modfetch.ProxyURL = p
	}

	if err := run(flag.Arg(0), *oracleModPath); err != nil {
		log.Fatal(err)
	}
}
