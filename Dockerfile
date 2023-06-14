FROM golang:1.20@sha256:519184356f970849c5f58764014c13ce20c3a3cadc13be7b8d87269bc5554ccd as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:73deaaf6a207c1a33850257ba74e0f196bc418636cada9943a03d7abea980d6d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
