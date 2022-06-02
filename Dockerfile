FROM golang:1.18@sha256:677784946a2e98ee8330911f5a00e2a948d0874e0abba0092a6081d7a3d998ba as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:6c7c6e523cb42cddaace37a9125014b51768f2761138dbb8c7fb722d57a988a0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
