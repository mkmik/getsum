FROM golang:1.19@sha256:4198e0e8c8577ab33e07e3241f77a446e9f480751b12192ed7ad7c273aebf8ea as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a215fd3bc92252f4d0e889cff3f3a820549d3e307c4ce98590cda3556d95e6d6
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
