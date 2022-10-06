FROM golang:1.19@sha256:96ee7727954a76a93004ffb0aadf53fb9a95da985f53ac66614d5722eaa0af93 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cefeffd60bd9127a3bb53dc83289cf1718a81710465d7377d9d25e8137b58c83
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
