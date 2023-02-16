FROM golang:1.19@sha256:7ce31d15a3a4dbf20446cccffa4020d3a2974ad2287d96123f55caf22c7adb71 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:db7ea5913b13bb5fc4a5f5ee5a1fab693d262846d3e7b28efd3f8f62f835c161
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
