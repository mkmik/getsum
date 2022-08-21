FROM golang:1.18@sha256:616aa980e2a8f3944baf5975d475f6ef1a3e50f1ec56fecd2e88280f5d1b4bf2 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:c4ad5921a0ba40c1726559fbd39cc308e2658a2ce86cc997afb80f1090c71ed6
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
