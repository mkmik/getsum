FROM golang:1.18@sha256:fb5993c8c22ae9fec57f91a3e59825f9368d01b1d15a984d83080cac575f79b8 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:b0216a38315e7d4e14a70338f4bcfdf622bcd2ca2f3fcb48de446c4bb51f7243
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
