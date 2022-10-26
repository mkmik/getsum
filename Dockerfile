FROM golang:1.19@sha256:e08482b7e60a61bc400b27de8d0b7aa83bd6cfff0cac02dac89c6f24b26ed441 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:122585ba4c098993df9f8dc7285433e8a19974de32528ee3a4b07308808c84ce
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
