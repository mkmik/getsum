FROM golang:1.21@sha256:c048e5cccb0b6a4447ac117156e7d3ff315fc1a39f15a00a684e53f4af684ee4 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:1aae189e3baecbb4044c648d356ddb75025b2ba8d14cdc9c2a19ba784c90bfb9
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
