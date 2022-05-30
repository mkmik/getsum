FROM golang:1.18@sha256:04fab5aaf4fc18c40379924674491d988af3d9e97487472e674d0b5fd837dfac as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:6c7c6e523cb42cddaace37a9125014b51768f2761138dbb8c7fb722d57a988a0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
