FROM golang:1.20@sha256:2edf6aab2d57644f3fe7407132a0d1770846867465a39c2083770cf62734b05d as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:db7ea5913b13bb5fc4a5f5ee5a1fab693d262846d3e7b28efd3f8f62f835c161
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
