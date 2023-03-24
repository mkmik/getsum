FROM golang:1.20@sha256:8114f4a1bfba75e753d87fbad6a9f23d09746890df3e7749dc82bf5049d4f5fa as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:2c50b819aa3bfaf6ae72e47682f6c5abc0f647cf3f4224a4a9be97dd30433909
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
