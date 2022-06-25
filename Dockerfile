FROM golang:1.18@sha256:a452d6273ad03a47c2f29b898d6bb57630e77baf839651ef77d03e4e049c5bf3 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cd46126707e268844faec3aca618761c6728170e08ccf1f174dbc7ed7ca1b36a
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
