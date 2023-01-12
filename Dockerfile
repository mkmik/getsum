FROM golang:1.19@sha256:bb9811fad43a7d6fd2173248d8331b2dcf5ac9af20976b1937ecd214c5b8c383 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9e6e03068e43358fd02a9bb967f5735587673c0ede0267b4d0d1cd0e0142bc08
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
