FROM golang:1.18@sha256:90c06f42c1aa2b6b96441c0e6192aff48815cf5e7950cd661ed316fdbfb06ed4 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cd46126707e268844faec3aca618761c6728170e08ccf1f174dbc7ed7ca1b36a
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
