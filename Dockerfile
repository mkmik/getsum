FROM golang:1.20@sha256:010a0ffe47398a3646993df44906c065c526eabf309d01fb0cbc9a5696024a60 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:73deaaf6a207c1a33850257ba74e0f196bc418636cada9943a03d7abea980d6d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
