// Package getsum provides types for getsum oracles.
//
// Oracles are a Go DSL which allows us to declare hashes of external URLs.
// They are not meant to be directly executed but instead to be parsed with go/parser
// by the getsum cmd.
package getsum

const (
	// CanonicalVersion is the version we expect oracles to be released at.
	CanonicalVersion = "v0.0.2"
)

// File declares an oracle for a single file
func File(url, hash string) {
}

// Dir declares an oracle for whole directory. shasum is the body of the output of the standard UNIX
// sha256sum utility listing all files in the directory.
func Dir(base, shasum string) {
}
