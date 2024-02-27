FROM golang:1.21@sha256:549dd88a1a53715f177b41ab5fee25f7a376a6bb5322ac7abe263480d9554021 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:acdc4f695bd57daad39cf7d305db57eb53ed806c9e894e5249ad58a9cfae370f
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
