package main

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/mkmik/getsum/pkg/oracle"
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
	var meta string
	if len(r.URL.Path) > 1 {
		scheme := "https"
		if strings.HasPrefix(r.Host, "localhost:") {
			scheme = "http"
		}
		dom := strings.SplitN(r.Host, ":", 2)[0]
		mod, err := oracle.EncodeURLToModulePath("https://" + r.URL.Path[1:])
		if err != nil {
			reportError(w, r, err)
			return
		}
		meta = fmt.Sprintf(`<meta name="go-import" content="%s/%s mod %s://%s">`, dom, mod, scheme, r.Host)
	}

	body := fmt.Sprintf(`
	<p>TODO</p>
	<pre>%s</pre>`, template.HTMLEscapeString(meta))

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

func reportError(w http.ResponseWriter, r *http.Request, err error) {
	if os.IsNotExist(err) {
		http.Error(w, err.Error(), http.StatusNotFound)
		return
	}
	http.Error(w, err.Error(), http.StatusInternalServerError)
}

func main() {
	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Listening on port %s\n", port)

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
