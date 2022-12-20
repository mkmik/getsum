FROM golang:1.19@sha256:54184d6d892f9d79dd332a6794bb11085c3f8b31f8be8e0911bed4df80044c93 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:bcc07c85faacd679fa8581d0d7d02b68b76baa2bdcab52c51560dcaee47b104e
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
