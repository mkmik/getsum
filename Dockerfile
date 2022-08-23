FROM golang:1.18@sha256:a0bffde64555bb29b8c2cdc887bdf638607e876ee50d7aed0a6d8b1a0de98d8c as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:c4ad5921a0ba40c1726559fbd39cc308e2658a2ce86cc997afb80f1090c71ed6
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
