FROM golang:1.21@sha256:81811f8a883e238666dbadee6928ae2902243a3cd3f3e860f21c102543c6b5a7 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9bc3117a99c731a41200a28774405125cb6fbda1819f4a1af88bd3bfad5dcf32
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
