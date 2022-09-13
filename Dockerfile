FROM golang:1.19@sha256:7aa8e69111c032e649bfd11439ff133a18f68d1028f138526592b76866985228 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:c06bf48fa67dab06db6027109d3d802aa5b7d213c86a9eabc4d83f806d18ce1c
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
