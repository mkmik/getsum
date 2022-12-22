FROM golang:1.19@sha256:660f138b4477001d65324a51fa158c1b868651b44e43f0953bf062e9f38b72f3 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:bcc07c85faacd679fa8581d0d7d02b68b76baa2bdcab52c51560dcaee47b104e
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
