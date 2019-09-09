package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"path"
	"regexp"
	"strings"
	"time"

	"getsum.pub/getsum/pkg/manifest"
	"getsum.pub/getsum/pkg/oracle"
	"getsum.pub/getsum/pkg/sumfetch"
)

var (
	mainTemplate = template.Must(template.New("foo").Parse(`<html lang="en">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  {{.Head}}
  <title>Immutable Artifact Checksum Database</title>
  <style>
    .container {
      font-size: 1.6em;
      line-height: 1.4;
      margin: 3.5em auto;
      max-width: 45em;
      padding: 0 1.5em;
    }
    body {
      font: 62.5% Arial, sans-serif;
    }
    code {
      background-color: #f0f8ff;
    }
  </style>

  <div class="container">
  <h1>Immutable Artifact Checksum Database</h1>
  {{.Body}}
  </div>
</html>
`))
)

type mainTemplateData struct {
	Head template.HTML
	Body template.HTML
}

func handler(w http.ResponseWriter, r *http.Request) {
	var goImportContent string

	if strings.SplitN(r.URL.Path[1:], "/", 2)[0] == "getsum" {
		goImportContent = "getsum.pub/getsum git https://github.com/mkmik/getsum"
	} else if len(r.URL.Path) > 1 {
		scheme := "https"
		if strings.HasPrefix(r.Host, "localhost:") {
			scheme = "http"
		}
		mod := r.URL.Path[1:]
		goImportContent = fmt.Sprintf("getsum.pub/%s mod %s://%s/@proxy/", mod, scheme, r.Host)
	}

	var meta string
	if goImportContent != "" {
		meta = fmt.Sprintf(`<meta name="go-import" content="%s">`, goImportContent)
	}

	body := fmt.Sprintf(`
	<p>Read more about it at <a href="https://github.com/mkmik/getsum">https://github.com/mkmik/getsum</a></p>
	<pre>%s</pre>`, template.HTMLEscapeString(goImportContent))

	data := &mainTemplateData{
		Head: template.HTML(meta),
		Body: template.HTML(body),
	}
	err := mainTemplate.Execute(w, data)
	if err != nil {
		reportError(w, r, err)
		return
	}
}

var proxyMethodRegexp = regexp.MustCompile(`^/@proxy/(.*)/@v/(.*)$`)

func matchProxyURL(r *http.Request) (string, string, bool) {
	s := proxyMethodRegexp.FindStringSubmatch(r.URL.Path)
	if s == nil {
		return "", "", false
	}
	return s[1], s[2], true
}

func handleProxy(w http.ResponseWriter, r *http.Request) {
	modulePath, method, ok := matchProxyURL(r)
	if !ok {
		http.Error(w, "unknown proxy url", http.StatusNotFound)
		return
	}

	if method == "list" {
		fmt.Fprintln(w, manifest.CanonicalVersion)
		return
	}

	ext := path.Ext(method)
	version := method[:len(method)-len(ext)]

	if version != manifest.CanonicalVersion {
		http.Error(w, fmt.Sprintf("unknown revision %s", version), http.StatusNotFound)
		return
	}

	var err error
	switch ext {
	case ".info":
		info := struct {
			Version string    // version string
			Time    time.Time // commit time
		}{
			Version: manifest.CanonicalVersion,
			// Time: epoch
		}
		err = json.NewEncoder(w).Encode(info)
	case ".mod":
		err = oracle.WriteGoMod(w, modulePath)
	case ".zip":
		u, err := oracle.DecodeURLFromModulePath(modulePath)
		if err != nil {
			reportError(w, r, err)
			return
		}
		h, err := fetchHash(u)
		if err != nil {
			reportError(w, r, err)
			return
		}
		err = oracle.WriteZip(w, modulePath, version, map[string]string{u: h})
	default:
		fmt.Fprintf(w, "unknown extension %q\n", ext)
	}
	if err != nil {
		reportError(w, r, err)
	}
}

func fetchHash(artifactURL string) (string, error) {
	sf, err := sumfetch.FetchSumFile(artifactURL)
	if err != nil {
		return "", err
	}
	return sf.HashForURL(artifactURL)
}

func reportError(w http.ResponseWriter, r *http.Request, err error) {
	if os.IsNotExist(err) {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	http.Error(w, err.Error(), http.StatusInternalServerError)
}

func main() {
	http.Handle("/robots.txt", http.NotFoundHandler())
	http.Handle("/favicon.ico", http.NotFoundHandler())
	http.HandleFunc("/@proxy/", handleProxy)
	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on port %s\n", port)

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
