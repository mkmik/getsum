FROM golang:1.19@sha256:27ff940e5e460ef6dc80311c7bb9c633871bb99a1f45e190fa29864a1ea7209a as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cefeffd60bd9127a3bb53dc83289cf1718a81710465d7377d9d25e8137b58c83
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
