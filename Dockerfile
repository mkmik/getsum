FROM golang:1.19@sha256:06fc512f4d8d2e7873132386f535e998b656404a9eba8a9a3084d9916d2c6e73 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9e6e03068e43358fd02a9bb967f5735587673c0ede0267b4d0d1cd0e0142bc08
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
