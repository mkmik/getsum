FROM golang:1.20@sha256:2edf6aab2d57644f3fe7407132a0d1770846867465a39c2083770cf62734b05d as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:c6004931c0f93208ae1631a212fa77a16aadc27fbf2fd2429d0bc5cfa44df7db
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
