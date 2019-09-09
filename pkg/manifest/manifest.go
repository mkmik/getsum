// Package manifest provides types for getsum witnesss.
//
// Witnesss are a Go DSL which allows us to declare hashes of external URLs.
// They are not meant to be directly executed but instead to be parsed with go/parser
// by the getsum cmd.
package manifest

const (
	// CanonicalVersion is the version we expect witnesss to be released at.
	CanonicalVersion = "v0.0.4"
)

// File declares an witness for a single file
func File(url, hash string) {
}

// Dir declares an witness for whole directory. shasum is the body of the output of the standard UNIX
// sha256sum utility listing all files in the directory.
func Dir(base, shasum string) {
}
