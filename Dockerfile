FROM golang:1.21@sha256:191676f3f6cb31c02232dfa2eaaf6b27b84c4efda73e47160ac86d49a91448fc as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:6c1e34e2f084fe6df17b8bceb1416f1e11af0fcdb1cef11ee4ac8ae127cb507c
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
