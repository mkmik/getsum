FROM golang:1.18@sha256:9b3c69af3b8b97969d1b1294d45ab70fbcfaadc8828e21062071d2955278d918 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:6c7c6e523cb42cddaace37a9125014b51768f2761138dbb8c7fb722d57a988a0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
