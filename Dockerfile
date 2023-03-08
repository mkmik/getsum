FROM golang:1.20@sha256:74a382917f6eaa7cc2d000dc2cd412a7f823f343b3b6268b20d84d057bc56718 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:7e09a4246ef6a8d75337141b8fbaef19dc0d25ad460a28b14701e5c0cdccf0ea
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
