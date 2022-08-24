FROM golang:1.19@sha256:d3f734e1f46ec36da8c1bce67cd48536138085289e24cfc8765f483c401b7d96 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:c4ad5921a0ba40c1726559fbd39cc308e2658a2ce86cc997afb80f1090c71ed6
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
