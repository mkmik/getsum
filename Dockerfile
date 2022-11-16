FROM golang:1.19@sha256:241ae1a3d3c67a7285010eae710adaf58b7f6c54864155a389ea4229ce67a9ee as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a215fd3bc92252f4d0e889cff3f3a820549d3e307c4ce98590cda3556d95e6d6
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
