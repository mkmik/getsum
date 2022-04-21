FROM golang:1.18@sha256:a64d159a88cc3e259c72b2ee1fe64ad1f91022fde11a30399010e21313abff42 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:ce8bc342dd7eeb0baccbef2ce00afc0c72af1ea166794f55ef8f434fd7c8b515
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
