FROM golang:1.17@sha256:c7c94588b6445f5254fbc34df941afa10de04706deb330e62831740c9f0f2030 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:03dcbf61f859d0ae4c69c6242c9e5c3d7e1a42e5d3b69eb235e81a5810dd768e
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
