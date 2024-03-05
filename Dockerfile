FROM golang:1.21@sha256:c82d4ad02c062cf2b393bf0374df26638c6fed3dfe52cdbd3635d4a7befab86e as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9d4e5680d67c984ac9c957f66405de25634012e2d5d6dc396c4bdd2ba6ae569f
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
