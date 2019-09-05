package main

import (
	"archive/zip"
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"io"
	"io/ioutil"
	"os"
	"path"
	"strconv"
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

func parseOracle(zipFileName string) (*oracle, error) {
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
					if mod.Name == "getsum" && s.Sel.Name == "File" {
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
