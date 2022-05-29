FROM golang:1.18@sha256:9dafe59cb3b7a492ef75295816b9f4a0f42ec8c494035212c8519ecc4f79f1d2 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:6c7c6e523cb42cddaace37a9125014b51768f2761138dbb8c7fb722d57a988a0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
