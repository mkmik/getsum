FROM golang:1.19@sha256:572f68065ea605e0bd7ab42aa036462318e680a15db0f41a0cadcd06affdabdb as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:72e71f914972dd6330ddd2c129b01901b46ab86e8ffbeb3a2aeb79036f88e91b
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
