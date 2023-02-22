FROM golang:1.20@sha256:2edf6aab2d57644f3fe7407132a0d1770846867465a39c2083770cf62734b05d as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:ccaef5ee2f1850270d453fdf700a5392534f8d1a8ca2acda391fbb6a06b81c86
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
