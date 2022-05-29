FROM golang:1.18@sha256:a6acd837e689ef9741a710ebd6db4c162ce82e0c8f443891eb694a6e8a494978 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:6c7c6e523cb42cddaace37a9125014b51768f2761138dbb8c7fb722d57a988a0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
