FROM golang:1.21@sha256:cb68d581d97423562b0a4416514866854c0b28a863b6feac929a54a73412fdfd as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:46c5b9bd3e3efff512e28350766b54355fce6337a0b44ba3f822ab918eca4520
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
