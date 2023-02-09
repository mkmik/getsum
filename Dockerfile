FROM golang:1.19@sha256:07b445822561ebca481b456b5673c05f80f822ea7b0d45d6cbcb9b2ff1a4e023 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:12a2e42b7a438f4470694942d787d61188e922ab25df49f17947d08f19e9d71f
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
