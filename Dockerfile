FROM golang:1.21@sha256:397952c5ffa5bfeca2a9acf2e56b6d9904df09341b293695975e64a2d66f4cef as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a35b6525fde5572656e24109064dd147fbaedc26e5a7ccd147ff3ed3a4308c21
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
