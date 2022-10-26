FROM golang:1.19@sha256:8c64868126d0df5190eda8dfd6bf065fe9b229a5e0c707ebfdea3ac0f5e9eadf as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:122585ba4c098993df9f8dc7285433e8a19974de32528ee3a4b07308808c84ce
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
