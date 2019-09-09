// Package sumfile parses the output of the familiy of checksum commands: md5sum, sha256sum, ...
package sumfile

import (
	"bufio"
	"fmt"
	"io"
	"regexp"
)

type SumFile map[string]string

// Parse parses a "sum file" body.
func Parse(r io.Reader) (SumFile, error) {
	res := SumFile{}

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		h, f, err := splitLine(scanner.Text())
		if err != nil {
			return nil, err
		}
		res[f] = h
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return res, nil
}

func splitLine(l string) (string, string, error) {
	var sumRegexp = regexp.MustCompile(`([a-zA-Z0-9]*) [ *](.*)`)

	m := sumRegexp.FindStringSubmatch(l)
	if m == nil {
		return "", "", fmt.Errorf("line doesn't match sum syntax")
	}
	return m[1], m[2], nil
}