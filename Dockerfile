FROM golang:1.19@sha256:09009d430dbf3fb80a4731546eefb1603f1fdb36fe6354eab138d8275a85e89f as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:b9c7d9344b1d95e57f7bd17a90137d8351541d06d80f2596dd0de6c2a4aae6a3
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
