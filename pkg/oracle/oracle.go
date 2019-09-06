package oracle

import (
	"archive/zip"
	"encoding/base32"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io"
	"io/ioutil"
	"net/url"
	"os"
	"path"
	"strconv"
	"strings"
)

type oracle struct {
	hashes map[string]string
}

func newOracleForFile(url, hash string) *oracle {
	return &oracle{
		hashes: map[string]string{url: hash},
	}
}

func (o *oracle) Hash(url string) (string, error) {
	if h, ok := o.hashes[url]; ok {
		return h, nil
	}
	return "", fmt.Errorf("cannot find hash for URL: %q", url)
}

// WriteGoMod writes a go.mod file for an oracle.
func WriteGoMod(w io.Writer, modulePath string) error {
	_, err := fmt.Fprintf(w,
		`module %s

go 1.13

require getsum.pub/getsum v0.0.4
`, modulePath)
	return err
}

// WriteZip generates a Go module body containing an oracle declaring hashes for one or more URLs.
func WriteZip(w io.Writer, modulePath, version string, hashes map[string]string) error {
	z := zip.NewWriter(w)
	defer z.Close()

	dir := fmt.Sprintf("%s@%s", modulePath, version)

	mod, err := z.Create(path.Join(dir, "go.mod"))
	if err != nil {
		return err
	}
	if err := WriteGoMod(mod, modulePath); err != nil {
		return err
	}

	main, err := z.Create(path.Join(dir, "main.go"))
	if err != nil {
		return err
	}
	if err := writeMainGo(main, hashes); err != nil {
		return err
	}
	return nil
}

func writeMainGo(w io.Writer, hashes map[string]string) error {
	if got, want := len(hashes), 1; got != want {
		return fmt.Errorf("unsupported map len %d, want: %d", got, want)
	}

	// take the first and only url
	var u string
	for k := range hashes {
		u = k
	}

	_, err := fmt.Fprintf(w, `package main

import "getsum.pub/getsum/pkg/manifest"

func main() {
	manifest.File(
		%q,
		%q,
	)
}
`, u, hashes[u])
	return err
}

// ParseFromZip parses an oracle from a zip file.
// The Zip file should contain a Go module, archived as defined by the goproxy protocol.
func ParseFromZip(zipFileName string) (*oracle, error) {
	zf, err := os.Open(zipFileName)
	if err != nil {
		return nil, err
	}
	defer zf.Close()
	st, err := zf.Stat()
	if err != nil {
		return nil, err
	}

	zr, err := zip.NewReader(zf, st.Size())
	if err != nil {
		return nil, err
	}

	for _, f := range zr.File {
		if path.Base(f.Name) == "main.go" {
			m, err := f.Open()
			if err != nil {
				return nil, err
			}
			defer m.Close()
			return parseOracleMain(m)
		}
	}
	return nil, fmt.Errorf("cannot find main.go in oracle")
}

// EncodeURLToModule encodes an arbitrary URL into a form that is compatible with Go module/import paths.
func EncodeURLToModulePath(u string) (string, error) {
	ur, err := url.Parse(u)
	if err != nil {
		return "", err
	}

	rest := strings.Split(ur.Path, "/")[1:]
	for i := range rest {
		rest[i] = toBase32(rest[i])
	}
	p := fmt.Sprint(ur.Host, "/", strings.Join(rest, "/"))
	if strings.HasSuffix(p, "/") {
		return "", fmt.Errorf("directories not supported")
	}
	return p, nil
}

// DecodeURLFromModulePath is the inverse of EncodeURLToModulePath.
func DecodeURLFromModulePath(modulePath string) (string, error) {
	c := strings.Split(modulePath, "/")
	rest := c[1:]
	var err error
	for i := range rest {
		rest[i], err = fromBase32(rest[i])
		if err != nil {
			return "", err

		}
	}
	return fmt.Sprintf("https://%s/%s", c[0], strings.Join(rest, "/")), nil
}

var base32Encoding = base32.StdEncoding.WithPadding(base32.NoPadding)

func toBase32(s string) string {
	return strings.ToLower(base32Encoding.EncodeToString([]byte(s)))
}

func fromBase32(b string) (string, error) {
	r, err := base32Encoding.DecodeString(strings.ToUpper(b))
	if err != nil {
		return "", fmt.Errorf("error while decoding %q: %v", b, err)
	}
	return string(r), nil
}

func parseOracleMain(r io.Reader) (*oracle, error) {
	mainGo, err := ioutil.TempFile("", "*.go")
	if err != nil {
		return nil, err
	}
	defer os.RemoveAll(mainGo.Name())
	if _, err := io.Copy(mainGo, r); err != nil {
		return nil, err
	}
	mainGo.Close()

	var fset token.FileSet
	top, err := parser.ParseFile(&fset, mainGo.Name(), nil, 0)
	if err != nil {
		return nil, err
	}

	var vis astVisitor
	ast.Walk(&vis, top)

	if vis.url == "" {
		return nil, fmt.Errorf("cannot find a manifest declaration in main.go")
	}

	return newOracleForFile(vis.url, vis.hash), vis.err
}

type astVisitor struct {
	url  string
	hash string
	err  error
}

func (v *astVisitor) Visit(node ast.Node) (w ast.Visitor) {
	switch n := node.(type) {
	case *ast.File:
		return v
	case *ast.FuncDecl:
		if n.Name.Name == "main" {
			return v
		}
	case *ast.BlockStmt:
		return v
	case *ast.ExprStmt:
		if c, ok := n.X.(*ast.CallExpr); ok {
			if s, ok := c.Fun.(*ast.SelectorExpr); ok {
				if mod, ok := s.X.(*ast.Ident); ok {
					if mod.Name == "manifest" && s.Sel.Name == "File" {
						v.url, v.hash, v.err = parseFileAST(c.Args)
					}
				}
			}
		}
	}
	return nil
}

func parseFileAST(args []ast.Expr) (string, string, error) {
	if got, want := len(args), 2; got != want {
		return "", "", fmt.Errorf("expecting %d arguments got %d", want, got)
	}
	url, err := getStringLit(args[0])
	if err != nil {
		return "", "", err
	}
	hash, err := getStringLit(args[1])
	if err != nil {
		return "", "", err
	}
	return url, hash, nil
}

func getStringLit(expr ast.Expr) (string, error) {
	bl, ok := expr.(*ast.BasicLit)
	if !ok {
		return "", fmt.Errorf("expecting ast.BasicLit, got %T", expr)
	}
	s, err := strconv.Unquote(bl.Value)
	if err != nil {
		return "", err
	}
	return s, nil
}
