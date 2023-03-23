FROM golang:1.20@sha256:a401b5e85b429f12c9b11063c3b8b1e88a76e3acf57c162b32120980c10c45bf as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:2c50b819aa3bfaf6ae72e47682f6c5abc0f647cf3f4224a4a9be97dd30433909
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
