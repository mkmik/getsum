FROM golang:1.19@sha256:25de7b6b28219279a409961158c547aadd0960cf2dcbc533780224afa1157fd4 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:1247d3b7a3e9bf429a12208a3ff2f6631b8c24b4d13bca803477ec7dab750069
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
