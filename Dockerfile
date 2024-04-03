FROM golang:1.21@sha256:7d0dcbe5807b1ad7272a598fbf9d7af15b5e2bed4fd6c4c2b5b3684df0b317dd as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9bc3117a99c731a41200a28774405125cb6fbda1819f4a1af88bd3bfad5dcf32
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
