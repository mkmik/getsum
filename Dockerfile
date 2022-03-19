FROM golang:1.18@sha256:975f5ba172bf536b32a30642f1cb1915a2cda58e94a15926cf7fae2219a5f5dd as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:b0216a38315e7d4e14a70338f4bcfdf622bcd2ca2f3fcb48de446c4bb51f7243
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
