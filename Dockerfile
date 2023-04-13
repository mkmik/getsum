FROM golang:1.20@sha256:403f48633fb5ebd49f9a2b6ad6719f912df23dae44974a0c9445be331e72ff5e as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:e711a716d8b7fe9c4f7bbf1477e8e6b451619fcae0bc94fdf6109d490bf6cea0
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
