FROM golang:1.20@sha256:b9709ec43c46394c353ecd88bda92b1fa2dbafe4f890c805f51e3ee9ee7b0664 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:e711a716d8b7fe9c4f7bbf1477e8e6b451619fcae0bc94fdf6109d490bf6cea0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
